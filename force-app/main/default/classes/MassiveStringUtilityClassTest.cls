@isTest
public class MassiveStringUtilityClassTest {

    @isTest
    static void testReverse() {
        System.assertEquals('olleH', MassiveStringUtilityClass.reverse('Hello'), 'Reverse failed.');
    }

    @isTest
    static void testAreAnagrams() {
        System.assertEquals(true, MassiveStringUtilityClass.areAnagrams('listen', 'silent'), 'Anagram check failed.');
    }

    @isTest
    static void testCountWords() {
        System.assertEquals(5, MassiveStringUtilityClass.countWords('This is a test string'), 'Word count failed.');
    }

    @isTest
    static void testIsNumeric() {
        System.assertEquals(true, MassiveStringUtilityClass.isNumeric('12345'), 'Numeric check failed.');
    }

    @isTest
    static void testRemoveSpaces() {
        System.assertEquals('HelloWorld', MassiveStringUtilityClass.removeSpaces('Hello World'), 'Remove spaces failed.');
    }

    @isTest
    static void testCapitalizeWords() {
        System.assertEquals('Hello World', MassiveStringUtilityClass.capitalizeWords('hello world'), 'Capitalize words failed.');
    }

    @isTest
    static void testIsPalindrome() {
        System.assertEquals(true, MassiveStringUtilityClass.isPalindrome('A man a plan a canal Panama'), 'Palindrome check failed.');
    }

    @isTest
    static void testJoinWithDelimiter() {
        List<String> input = new List<String>{'Apple', 'Banana', 'Cherry'};
        System.assertEquals('Apple-Banana-Cherry', MassiveStringUtilityClass.joinWithDelimiter(input, '-'), 'Join failed.');
    }

    @isTest
    static void testCountCharacterOccurrences() {
        System.assertEquals(3, MassiveStringUtilityClass.countCharacterOccurrences('banana', 'a'), 'Character count failed.');
    }

    @isTest
    static void testReplaceVowels() {
        System.assertEquals('H*ll*', MassiveStringUtilityClass.replaceVowels('Hello', '*'), 'Replace vowels failed.');
    }

    @isTest
    static void testFindLongestWord() {
        System.assertEquals('longest', MassiveStringUtilityClass.findLongestWord('Find the longest word'), 'Longest word failed.');
    }

    @isTest
    static void testSplitByDelimiter() {
        List<String> result = MassiveStringUtilityClass.splitByDelimiter('apple,banana,cherry', ',');
        System.assertEquals(3, result.size(), 'Split failed.');
    }

    @isTest
    static void testStartsWithPrefix() {
        System.assertEquals(true, MassiveStringUtilityClass.startsWithPrefix('Salesforce', 'Sales'), 'Prefix check failed.');
    }

    @isTest
    static void testToCamelCase() {
        System.assertEquals('helloWorld', MassiveStringUtilityClass.toCamelCase('Hello World'), 'Camel case conversion failed.');
    }
}