class SemesterHelper {
  static String calculateSemester(
      String npm, int periodYearStart, String oddEven) {
    try {
      // NPM Format: 06.2023.1.07663 -> Year is at index 1 (2023)
      // Assuming NPM is always separated by '.'
      final parts = npm.split('.');
      if (parts.length < 2) return "Semester ?";

      final entryYear = int.parse(parts[1]);
      final diff = periodYearStart - entryYear;

      // Logic: (Year Diff * 2) + (Gasal=1, Genap=2)
      // Example: 2023 Start, 2023 Gasal -> (0*2) + 1 = Sem 1
      // Example: 2023 Start, 2023 Genap -> (0*2) + 2 = Sem 2
      // Example: 2024 Start, 2024 Gasal -> (1*2) + 1 = Sem 3

      int oddEvenValue = 2; // Default to Genap/2
      final oeAuth = oddEven.toString().toLowerCase().trim();
      if (oeAuth == "1" || oeAuth == "gasal" || oeAuth == "ganjil") {
        oddEvenValue = 1;
      }

      final semester = (diff * 2) + oddEvenValue;

      if (semester <= 0) return "Pra"; // Just in case
      return "$semester";
    } catch (e) {
      return "?";
    }
  }

  static String calculateCalendarYear(int yearStart, String oddEven) {
    try {
      final oeAuth = oddEven.toString().toLowerCase().trim();
      if (oeAuth == "1" || oeAuth == "gasal" || oeAuth == "ganjil") {
        return yearStart.toString();
      } else {
        // Semester Genap terjadi di awal tahun kalender berikutnya
        return (yearStart + 1).toString();
      }
    } catch (e) {
      return yearStart.toString();
    }
  }
}
