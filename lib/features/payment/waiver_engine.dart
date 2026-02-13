class WaiverEngine {

  static double calculateWaiverPercent(String grade) {
    switch (grade) {
      case "A+":
        return 50;
      case "A":
        return 45;
      case "A-":
        return 40;
      case "B":
        return 38;
      case "C":
        return 35;
      default:
        return 0;
    }
  }

  static double calculateFinalAmount({
    required double totalFee,
    required String grade,
  }) {
    final waiverPercent = calculateWaiverPercent(grade);
    final discount = (totalFee * waiverPercent) / 100;
    return totalFee - discount;
  }
}
