package com.uberanalyzer.model

data class RideData(val price: Double, val distanceKm: Double, val timeMin: Int, val category: RideCategory, val raw: String)

enum class RideCategory(val displayName: String, val weight: Double, val colorHex: String) {
    POP("99Pop", 1.0, "#FFFBC02D"), 
    COMFORT("99Comfort", 1.3, "#F21A237E"), 
    TAXI("99Taxi", 1.1, "#F2FF9800"), 
    NEGOCIA("99Negocia", 1.0, "#F24CAF50"),
    ENTREGA("99Entrega", 0.9, "#F2E65100"),
    UNKNOWN("99", 1.0, "#FFFBC02D");
    companion object {
        fun fromString(s: String) = when {
            s.contains("Comfort", true) -> COMFORT
            s.contains("Taxi", true) -> TAXI
            s.contains("Negocia", true) -> NEGOCIA
            s.contains("Entrega", true) -> ENTREGA
            s.contains("Pop", true) -> POP
            else -> UNKNOWN
        }
    }
}

enum class ScoreRating(val label: String, val colorHex: String) {
    EXCELLENT("Excelente", "#4CAF50"), GOOD("Boa", "#8BC34A"), AVERAGE("OK", "#FFC107"), BAD("Ruim", "#F44336");
    companion object {
        fun fromScore(s: Double) = when { s >= 8.0 -> EXCELLENT; s >= 6.0 -> GOOD; s >= 4.0 -> AVERAGE; else -> BAD }
    }
}
