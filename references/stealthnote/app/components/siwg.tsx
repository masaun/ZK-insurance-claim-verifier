"use client";

import React from "react";
import Image from "next/image";
import googleLogo from "@/assets/google.png";

const SignWithGoogleButton = (props: { onClick: () => void; isLoading: boolean, disabled: boolean }) => {
  return (
    <button onClick={() => props.onClick()} className="message-form-oauth-button" disabled={props.disabled}>
      {props.isLoading ? (
        <span className="spinner-icon" style={{ color: "black" }} />
      ) : (
        <>
          <Image
            src={googleLogo}
            alt="Google logo"
            width={24}
            height={24}
          />
        </>
      )}
    </button>
  );
};

export default SignWithGoogleButton;
