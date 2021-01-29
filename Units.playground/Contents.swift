import UIKit

/*
 3 data types:
 - Unit: describes a unit of measurement eg meter, second
 - Measurement: provides a single value combined with a Unit eg 23 meters
 - MeasurementFormatter: converts a measurement to a human-readable format
 */

// MARK: - Conversions

// 6 feet (with UnitLength class)
let heightFeet = Measurement(value: 6, unit: UnitLength.feet)
// convert to inches and meters
let heightInches = heightFeet.converted(to: UnitLength.inches)
let heightSensible = heightFeet.converted(to: UnitLength.meters)
// other weird units
let furlongs = heightFeet.converted(to: UnitLength.furlongs)
let heightAUs = heightFeet.converted(to: UnitLength.astronomicalUnits)

// convert degrees to radians (with UnitAngle class)
let degrees = Measurement(value: 180, unit: UnitAngle.degrees)
let radians = degrees.converted(to: .radians)

// convert square meters to square centimeters (with UnitArea class)
let squareMeters = Measurement(value: 4, unit: UnitArea.squareMeters)
let squareCentimeters = squareMeters.converted(to: .squareCentimeters)

// convert bushels to imperial teaspoons (with UnitVolume class)
let bushels = Measurement(value: 6, unit: UnitVolume.bushels)
let teaspoons = bushels.converted(to: .imperialTeaspoons)

// MARK: - Calculations

// multiply a Measurement by a number
let doubleHeight = heightFeet * 2

// add a Measurement to another Measurement
let firstLap = Measurement(value: 49, unit: UnitDuration.seconds)  // UnitDuration class
let secondLap = Measurement(value: 58, unit: UnitDuration.seconds)
let total = (firstLap + secondLap).converted(to: .minutes)

// add Measurements with different units
let thirdLap = Measurement(value: 1.3, unit: UnitDuration.minutes)
let total2 = (firstLap + secondLap + thirdLap).converted(to: .minutes)

// MARK: - Printing Measurement to users

let formatter = MeasurementFormatter()
let temperature = Measurement(value: 32, unit: UnitTemperature.celsius)  // UnitTemperature class
formatter.unitStyle = .long
formatter.locale = Locale(identifier: "en-GB")  // so formatter shows Celsius rather than Fahrenheit
formatter.unitOptions = .providedUnit  // so formatter uses the exact unit type you specified, rather than performing automatic conversion
let result = formatter.string(from: temperature)

