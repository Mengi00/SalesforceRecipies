public class MassiveStringUtilityClass {

    // 1. Reverse a given string
    public static String reverse(String input) {
        String result = '';
        for (Integer i = input.length() - 1; i >= 0; i--) {
            result += input.substring(i, i + 1);
        }
        return result;
    }

    // 2. Check if two strings are anagrams
    public static Boolean areAnagrams(String str1, String str2) {
        return sortString(str1).equals(sortString(str2));
    }

    // 3. Sort the characters in a string alphabetically
    public static String sortString(String input) {
        List<String> chars = new List<String>();
        for (Integer i = 0; i < input.length(); i++) {
            chars.add(input.substring(i, i + 1));
        }
        chars.sort();
        return String.join(chars, '');
    }

    // 4. Count the number of words in a string
    public static Integer countWords(String input) {
        if (input == null || input.trim().length() == 0) return 0;
        return input.split('\\s+').size();
    }

    // 5. Check if a string contains only digits
    public static Boolean isNumeric(String input) {
        return Pattern.matches('^\\d+$', input);
    }

    // 6. Remove all spaces from a string
    public static String removeSpaces(String input) {
        return input.replaceAll('\\s+', '');
    }

    // 7. Capitalize the first letter of each word in a sentence
    public static String capitalizeWords(String input) {
        List<String> words = input.split(' ');
        String result = '';
        for (String word : words) {
            if (word != null && word.length() > 0) {
                result += word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase() + ' ';
            }
        }
        return result.trim();
    }

    // 8. Check if a string is a palindrome (ignores case and spaces)
    public static Boolean isPalindrome(String input) {
        String cleanInput = input.replaceAll('\\s+', '').toLowerCase();
        return cleanInput.equals(reverse(cleanInput));
    }

    // 9. Join a list of strings with a given delimiter
    public static String joinWithDelimiter(List<String> inputList, String delimiter) {
        return String.join(inputList, delimiter);
    }

    // 10. Count the occurrence of a character in a string
    public static Integer countCharacterOccurrences(String input, String character) {
        Integer count = 0;
        for (Integer i = 0; i < input.length(); i++) {
            if (input.substring(i, i + 1).equals(character)) {
                count++;
            }
        }
        return count;
    }

    // 11. Replace vowels in a string with a given character
    public static String replaceVowels(String input, String replacement) {
        return input.replaceAll('[AEIOUaeiou]', replacement);
    }

    // 12. Find the longest word in a string
    public static String findLongestWord(String input) {
        List<String> words = input.split(' ');
        String longest = '';
        for (String word : words) {
            if (word.length() > longest.length()) {
                longest = word;
            }
        }
        return longest;
    }

    // 13. Split a string into a list of substrings by a delimiter
    public static List<String> splitByDelimiter(String input, String delimiter) {
        return input.split(delimiter);
    }

    // 14. Check if a string starts with a specific prefix
    public static Boolean startsWithPrefix(String input, String prefix) {
        return input.startsWith(prefix);
    }

    // 15. Convert a string to camel case
    public static String toCamelCase(String input) {
        input = capitalizeWords(input);
        return input.substring(0, 1).toLowerCase() + input.substring(1).replaceAll('\\s+', '');
    }
}