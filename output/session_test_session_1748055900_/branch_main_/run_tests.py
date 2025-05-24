from test_pig_latin import translate_to_pig_latin

# Test cases
test_cases = [
    ("", ""),
    ("Hello", "Ellohay"),
    ("apple", "appleway"),
    ("Hello, world!", "Ellohay, orldway!"),
    ("string", "ingstray"),
    ("three", "eethray"),
    ("The quick brown fox jumps over the lazy dog.", "Ethay uickqay ownbray oxfay umpsjay overway ethay azylay ogday."),
    ("my", "myay"),
    ("by", "byay"),
    ("PyThOn", "yThOnPay")
]

# Run tests
passed = 0
failed = 0

for input_text, expected_output in test_cases:
    result = translate_to_pig_latin(input_text)
    if result == expected_output:
        print(f"PASS: '{input_text}' -> '{result}'")
        passed += 1
    else:
        print(f"FAIL: '{input_text}' -> '{result}' (expected: '{expected_output}')")
        failed += 1

print(f"\nTest Results: {passed} passed, {failed} failed")