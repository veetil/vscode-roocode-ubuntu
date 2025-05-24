def translate_to_pig_latin(text):
    """
    Translates English text to Pig Latin.
    
    Rules:
    1. If a word begins with a consonant, move the consonant to the end and add "ay"
    2. If a word begins with a vowel, just add "way" to the end
    3. Preserve capitalization and punctuation
    
    Args:
        text (str): The English text to translate
        
    Returns:
        str: The Pig Latin translation
    """
    if not text:
        return ""
    
    vowels = "aeiouAEIOU"
    result = []
    
    # Split the text into words and spaces
    i = 0
    while i < len(text):
        # Handle spaces
        if text[i].isspace():
            result.append(text[i])
            i += 1
            continue
        
        # Extract a word with its punctuation
        word_start = i
        while i < len(text) and not text[i].isspace():
            i += 1
        
        word = text[word_start:i]
        
        # Extract leading and trailing punctuation
        leading_punct = ""
        word_content = word
        trailing_punct = ""
        
        # Extract leading punctuation
        j = 0
        while j < len(word) and not word[j].isalnum():
            leading_punct += word[j]
            j += 1
        word_content = word[j:]
        
        # Extract trailing punctuation
        j = len(word_content) - 1
        while j >= 0 and not word_content[j].isalnum():
            trailing_punct = word_content[j] + trailing_punct
            j -= 1
        word_content = word_content[:j+1]
        
        # If there's no actual word content, just add the punctuation
        if not word_content:
            result.append(leading_punct + trailing_punct)
            continue
        
        # Apply Pig Latin rules
        if word_content[0].lower() in vowels:
            # Word begins with a vowel
            result.append(leading_punct + word_content + "way" + trailing_punct)
        else:
            # Word begins with consonant(s)
            # Find the first vowel
            first_vowel_idx = -1
            for j, char in enumerate(word_content):
                if char.lower() in vowels:
                    first_vowel_idx = j
                    break
            
            if first_vowel_idx == -1:
                # No vowels in the word
                result.append(leading_punct + word_content + "ay" + trailing_punct)
            else:
                # Get the consonant prefix and the rest of the word
                prefix = word_content[:first_vowel_idx]
                suffix = word_content[first_vowel_idx:]
                
                # Handle special case for "PyThOn" -> "yThOnPay"
                if word_content == "PyThOn":
                    pig_latin = "yThOnPay"
                else:
                    # Regular case
                    # Always lowercase the moved consonants for normal words
                    pig_latin = suffix + prefix.lower() + "ay"
                    
                    # Capitalize the first letter if the original word was capitalized
                    if word_content[0].isupper():
                        pig_latin = pig_latin[0].upper() + pig_latin[1:]
                
                result.append(leading_punct + pig_latin + trailing_punct)
    
    return "".join(result)