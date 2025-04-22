// SPDX-License-Identifier: MIT

/**
 * @title Field to Bytes Converter
 * @dev - Converts a Field (bytes32) value to uint8Array
 * @param valueInFieldOfBytes32 - a Field (bytes32) value
 */
fn convert_field_bytes32_to_uint8_array(valueInFieldOfBytes32: Field) -> [u8; 32] {
    let uint8_array: [u8; 32] = valueInFieldOfBytes32.to_be_bytes();
    uint8_array

    // @dev - Example: Convert Field to bytes
    // let field = 2;
    // let bytes: [u8; 8] = field.to_be_bytes();
    // assert_eq(bytes, [0, 0, 0, 0, 0, 0, 0, 2]);
    // assert_eq(Field::from_be_bytes::<8>(bytes), field);
}