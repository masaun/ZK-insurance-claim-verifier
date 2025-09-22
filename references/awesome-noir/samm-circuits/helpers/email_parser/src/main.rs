use base64::{engine::general_purpose, Engine as _};
use eml_parser::{
    eml::{Eml, HeaderFieldValue},
    EmlParser,
};
use noir_bignum_paramgen::{bn_limbs, redc_limbs};
use num_bigint::BigUint;
use regex::Regex;
use rsa::RsaPublicKey;
use rsa::{pkcs8::DecodePublicKey, traits::PublicKeyParts};
use std::error::Error;
use std::fs::write;
use trust_dns_resolver::Resolver;

const MSG_HASH_LENGTH: usize = 44; // base64 hash
const MAX_HEADER_LENGTH: usize = 1024;
const MAX_EMAIL_ADDRESS_LENGTH: usize = 124;

#[derive(Clone, Debug)]
struct DkimHeader {
    selector: Option<String>,
    domain: Option<String>,
}

#[derive(Clone, Debug)]
pub struct RelaxedHeaders {
    from: String,
    content_type: String,
    mime_version: String,
    subject: String,
    message_id: String,
    date: String,
    to: String,
    dkim_signature: String,
}

fn main() {
    // load email from fs
    let eml = get_demo_eml();

    // Parse out the headers of the email
    let relaxed_headers = build_relaxed_headers(&eml);
    let (signed_headers, header_len) = to_signed_headers(&relaxed_headers);

    // Extract the DKIM-Signature header from the email
    let dkim_header = &eml
        .headers
        .iter()
        .find(|header| header.name == "DKIM-Signature")
        .unwrap()
        .value;

    // Parse the needed fields
    let parsed_header = parse_dkim_header(dkim_header);

    // Query the DNS for the DKIM public key
    let dkim_record = query_dkim_public_key(
        parsed_header.selector.as_ref().unwrap().as_str(),
        parsed_header.domain.as_ref().unwrap().as_str(),
    );

    // Extract the public key from the DKIM record
    let pem_key = extract_and_format_dkim_public_key(&dkim_record).unwrap();
    let public_key = RsaPublicKey::from_public_key_pem(&pem_key).unwrap();

    // extract signature
    let signature = extract_dkim_signature(&dkim_header.to_string());

    // get the padded sender address + length
    let (padded_sender, sender_len) = get_padded_sender(&eml);

    // get the padded recipient address + length
    let (padded_recipient, recipient_len) = get_padded_recipient(&eml);

    // get the padded recipient address + length
    let padded_subject = get_padded_subject(&eml);

    // build the prover.toml file
    build_prover_toml(
        &signed_headers,
        header_len,
        &signature,
        &public_key,
        &padded_recipient,
        recipient_len,
        &padded_sender,
        sender_len,
        &padded_subject,
        &eml,
    );
}

fn get_demo_eml() -> Eml {
    let current_dir = std::env::current_dir().unwrap();
    let filepath = current_dir.join("src").join("demo.eml");
    EmlParser::from_file(filepath.to_str().unwrap())
        .unwrap()
        .parse()
        .unwrap()
}

fn find_substring_start_index(main_vec: &[u8], sub_vec: &[u8]) -> Option<usize> {
    let main_str = std::str::from_utf8(main_vec).ok()?;
    let sub_str = std::str::from_utf8(sub_vec).ok()?;

    if !main_str.contains(sub_str) {
        return None;
    }

    main_str.find(sub_str)
}

fn extract_emails(text: String) -> Vec<String> {
    let re = Regex::new(r"(?:[\w\.-]+@[\w\.-]+\.\w+|\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b)").unwrap();
    
    re.captures_iter(&text)
        .filter_map(|cap| {
            let email = cap.get(0).map_or("", |m| m.as_str());
            Some(String::from(email))
        })
        .collect()
}

fn parse_dkim_header(dkim_header: &HeaderFieldValue) -> DkimHeader {
    let value = dkim_header.to_string();
    let regex_str = r"=([^;]+);";
    let s_regex = Regex::new(&format!("s{}", regex_str)).unwrap();
    let d_regex = Regex::new(&format!("d{}", regex_str)).unwrap();
    let s = s_regex
        .captures(&value)
        .and_then(|caps| caps.get(1).map(|m| m.as_str().to_string()));
    let d = d_regex
        .captures(&value)
        .and_then(|caps| caps.get(1).map(|m| m.as_str().to_string()));

    DkimHeader {
        selector: s,
        domain: d,
    }
}

fn query_dkim_public_key(selector: &str, domain: &str) -> String {
    println!("selector = {};", selector);
    println!("domain = {};", domain);
    let fqdn = format!("{}._domainkey.{}", selector, domain);
    let resolver = Resolver::from_system_conf().expect("Failed to create resolver");
    let mut record: String = "".to_string();
    if let Ok(response) = resolver.txt_lookup(fqdn.as_str()) {
        for txt in response.iter() {
            for txt_part in txt.iter() {
                if let Ok(txt_str) = std::str::from_utf8(txt_part) {
                    record.push_str(txt_str);
                }
            }
        }
    };
    record
}

fn extract_and_format_dkim_public_key(dkim_record: &str) -> Result<String, Box<dyn Error>> {
    // Extract the base64-encoded public key using regex
    let re = Regex::new(r"p=([^;]+)")?;
    let caps = re
        .captures(dkim_record)
        .ok_or("No public key found in DKIM record")?;
    let pubkey_b64 = caps.get(1).ok_or("Failed to capture public key")?.as_str();

    // Format the key into lines of 64 characters each
    let formatted_key = pubkey_b64
        .as_bytes()
        .chunks(64)
        .map(|chunk| std::str::from_utf8(chunk).unwrap())
        .collect::<Vec<&str>>()
        .join("\n");

    // Construct the PEM format key
    let pem_key = format!(
        "-----BEGIN PUBLIC KEY-----\n{}\n-----END PUBLIC KEY-----",
        formatted_key
    );

    Ok(pem_key)
}

fn extract_dkim_signature(dkim_header: &str) -> Vec<u8> {
    let re = Regex::new(r"b=([^;]+)").unwrap();
    let encoded_signature = re
        .captures(dkim_header)
        .and_then(|caps| caps.get(1).map(|m| clean_dkim_signature(m.as_str())))
        .unwrap();
    general_purpose::STANDARD.decode(encoded_signature).unwrap()
}

fn clean_dkim_signature(dkim_signature: &str) -> String {
    dkim_signature.replace(&['\t', '\r', '\n', ' '][..], "")
}

pub fn build_relaxed_headers(eml: &Eml) -> RelaxedHeaders {
    let headers = &eml.headers;
    let subject = eml.subject.clone().unwrap();
    let from = eml.from.as_ref().unwrap().to_string();
    let to = eml.to.as_ref().unwrap().to_string();
    // let from = eml.clone().from.unwrap().to_string();
    let content_type = headers
        .iter()
        .find(|header| header.name == "Content-Type")
        .unwrap()
        .value
        .to_string();
    let mime_version = headers
        .iter()
        .find(|header| header.name == "MIME-Version")
        .unwrap()
        .value
        .to_string();
    let message_id = headers
        .iter()
        .find(|header| header.name == "Message-Id")
        .unwrap()
        .value
        .to_string();
    let date = headers
        .iter()
        .find(|header| header.name == "Date")
        .unwrap()
        .value
        .to_string();
    let dkim_signature = headers
        .iter()
        .find(|header| header.name == "DKIM-Signature")
        .unwrap()
        .value
        .to_string();
    // remove signature from dkim field
    let patterns = ["; b=", ";\n\tb="];
    let result = patterns
        .iter()
        .enumerate() // Add the index of the pattern
        .filter_map(|(pattern_index, &pattern)| {
            dkim_signature
                .find(pattern)
                .map(|index| (pattern_index, index))
        })
        .min_by_key(|&(_, index)| index);

    let (b_index, offset) = match result {
        Some((offset, b_index)) => (b_index, offset),
        None => panic!("Failed to find the signature in the DKIM-Signature header"),
    };
    let dkim_signature = String::from(&dkim_signature[..b_index + 4 + offset]); // Include the '; b=' part
    return RelaxedHeaders {
        from,
        content_type,
        mime_version,
        subject,
        message_id,
        date,
        to,
        dkim_signature,
    };
}

pub fn to_signed_headers(relaxed_headers: &RelaxedHeaders) -> (Vec<u8>, u32) {
    let headers = vec![
        // h=To:From:Subject:Date:Message-Id:Content-Type:MIME-Version;
        format!("to:{}", relaxed_headers.to.clone()),
        format!("from:{}", relaxed_headers.from.clone()),
        format!("subject:{}", relaxed_headers.subject.clone()),
        format!("date:{}", relaxed_headers.date.clone()),
        format!("message-id:{}", relaxed_headers.message_id.clone()),
        format!("content-type:{}", relaxed_headers.content_type.clone()),
        format!("mime-version:{}", relaxed_headers.mime_version.clone()),
        format!("dkim-signature:{}", relaxed_headers.dkim_signature.clone()),
        
        // h=Message-Id:Date:Subject:To:From
        // format!("message-id:{}", relaxed_headers.message_id.clone()),
        // format!("date:{}", relaxed_headers.date.clone()),
        // format!("subject:{}", relaxed_headers.subject.clone()),
        // format!("to:{}", relaxed_headers.to.clone()),
        // format!("from:{}", relaxed_headers.from.clone()),
        // format!("dkim-signature:{}", relaxed_headers.dkim_signature.clone()),
    ];
    let header_str = headers.join("\r\n");
    let header_str = header_str.replace("\n\t", " ");
    let header = header_str.as_bytes();
    let header_len = header.len() as u32;
    let mut padded_header = vec![0u8; MAX_HEADER_LENGTH];
    padded_header[..header.len()].copy_from_slice(header);
    (padded_header, header_len)
}

pub fn make_header_string(header: &Vec<u8>) -> String {
    format!("let header: [u8; {}] = {:?};", header.len(), header)
}

pub fn build_prover_toml(
    header: &Vec<u8>,
    header_len: u32,
    signature: &Vec<u8>,
    public_key: &RsaPublicKey,
    padded_recipient: &Vec<u8>,
    recipient_len: u32,
    padded_sender: &Vec<u8>,
    sender_len: u32,
    padded_subject: &Vec<u8>,
    eml: &Eml,
) {
    let from_field = eml.from.as_ref().unwrap().to_string();
    let padded_from = from_field.as_bytes();
    let from_index = find_substring_start_index(header, padded_from).unwrap() - 5;
    let from_seq = format!("[from_seq]\nindex = {:?}\nlength = {:?}", from_index, from_field.len()+5);

    let to_field = eml.to.as_ref().unwrap().to_string();
    let padded_to = to_field.as_bytes();
    let to_index = find_substring_start_index(header, padded_to).unwrap() - 3;
    let to_seq = format!("[to_seq]\nindex = {:?}\nlength = {:?}", to_index, to_field.len()+3);

    let mut member_index = from_index + 5; 
    let sender_len = sender_len as usize;
    if (from_field.len() > sender_len) {
        member_index = member_index + from_field.len() - sender_len - 1;
    }
    let member_seq = format!("[member_seq]\nindex = {:?}\nlength = {:?}", member_index, sender_len);

    let mut relayer_index = to_index + 3; 
    let recipient_len = recipient_len as usize;
    if (to_field.len() > recipient_len) {
        relayer_index = relayer_index + to_field.len() - recipient_len - 1;
    }
    let relayer_seq = format!("[relayer_seq]\nindex = {:?}\nlength = {:?}", relayer_index, recipient_len);

    // make the header value
    let header = format!("[header]\nlen = {:?}\nstorage = {:?}", header_len, header);
    let header_len = format!("header_length = {}", header_len);
    // make the pubkey_modulus value
    let pubkey_modulus = format!(
        "[pubkey]\nmodulus = {}\nredc = {}",
        quote_hex(bn_limbs(public_key.n().clone(), 2048)),
        quote_hex(redc_limbs(public_key.n().clone(), 2048))
    );
    // make the reduction parameter for the pubkey
    let redc_params = format!(
        "redc_params_limbs = {}",
        quote_hex(redc_limbs(public_key.n().clone(), 2048))
    );
    // make the subject
    let padded_subject = format!("msg_hash = {:?}", padded_subject);
    // make the sender
    let padded_sender = format!("padded_member = {:?}", padded_sender);
    // make the recipient
    let padded_recipient = format!("[relayer]\nlen = {:?}\nstorage = {:?}", recipient_len, padded_recipient);
    // make the signature value
    let sig_limbs = bn_limbs(BigUint::from_bytes_be(signature), 2048);
    let signature = format!("signature = {}", quote_hex(sig_limbs));

    // format for toml content
    let toml_content = format!(
        "{}\n\n{}\n\n{}\n\n{}\n\n{}\n\n{}\n\n{}\n\n{}\n\n{}\n\n{}",
        signature,
        padded_sender,
        padded_subject,
        header,
        from_seq,
        member_seq,
        padded_recipient,
        to_seq,
        relayer_seq,
        pubkey_modulus,
    );

    // save to fs
    let current_dir = std::env::current_dir().expect("Failed to get current directory");
    let file_path = current_dir.join("Prover_email.toml");
    write(file_path, toml_content).expect("Failed to write to Prover.toml");
}

pub fn quote_hex(input: String) -> String {
    let hex_values: Vec<&str> = input
        .trim_matches(|c| c == '[' || c == ']')
        .split(", ")
        .collect();
    let quoted_hex_values: Vec<String> = hex_values
        .iter()
        .map(|&value| format!("\"{}\"", value))
        .collect();
    format!("[{}]", quoted_hex_values.join(", "))
}

pub fn get_padded_recipient(eml: &Eml) -> (Vec<u8>, u32) {
    let recipient = eml.to.as_ref().unwrap().to_string();
    let emails = extract_emails(recipient);
    let recipient = emails[emails.len()-1].as_bytes();
    let mut padded_recipient = vec![0u8; MAX_EMAIL_ADDRESS_LENGTH];
    let recipient_len = recipient.len() as u32;
    padded_recipient[..recipient.len()].copy_from_slice(recipient);
    (padded_recipient, recipient_len)
}

pub fn get_padded_sender(eml: &Eml) -> (Vec<u8>, u32) {
    let from_field = eml.from.as_ref().unwrap().to_string();
    let emails = extract_emails(from_field);
    let sender = emails[emails.len()-1].as_bytes();
    let mut padded_sender = vec![0u8; MAX_EMAIL_ADDRESS_LENGTH];
    let sender_len = sender.len() as u32;
    padded_sender[..sender.len()].copy_from_slice(sender);
    (padded_sender, sender_len)
}

pub fn get_padded_subject(eml: &Eml) -> Vec<u8> {
    // find the header with the recipient email address
    let subject = eml.subject.clone().unwrap();
    let subject = subject.as_bytes();
    let mut padded_subject = vec![0u8; MSG_HASH_LENGTH];
    padded_subject[..subject.len()].copy_from_slice(subject);
    padded_subject
}