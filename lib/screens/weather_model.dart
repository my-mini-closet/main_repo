class Weather {
  final double temp;
  final int tempMin;
  final int tempMax;
  final String weatherMain;
  final String? icon; // nullable로 변경

  Weather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.weatherMain,
    this.icon, // nullable로 변경
  });
}
