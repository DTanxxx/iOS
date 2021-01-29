import UIKit

// Extra onditionals
var action: String?
var stayOutTooLate = true
var nothingInBrain = true

if stayOutTooLate && nothingInBrain {
    action = "cruise"
}

print(action!)

if !stayOutTooLate && !nothingInBrain {
    action = "retreat"
}
// the action variable will only be set if both stayOutTooLate and nothingInBrain are false – the ! has flipped them around.

print(action!)





// Extra loops
// The half open range operator looks like ..< and counts from one number up to and excluding another. For example, 1 ..< 5 will count 1, 2, 3, 4.

// You can also use the for i in loop construct to loop through arrays, because you can use that constant to index into an array. We could even use it to index into two arrays, like this:
var people = ["players", "haters", "heart-breakers", "fakers"]
var actions = ["play", "hate", "break", "fake"]

for i in 0 ... 3 {
    print("\(people[i]) gonna \(actions[i])")
}

// or:
for i in 0 ..< people.count {
    print("\(people[i]) gonna \(actions[i])")
}





// Switch Case
let liveAlbums = 2

switch liveAlbums {
case 0:
    print("You're just starting out")
case 1:
    print("You just released iTunes Live From SoHo")
case 2:
    print("You just released Speak Now World Tour")
default:
    print("Have you done something new?")
}
// Very convenient compared to using if statement

// Testing for a range of values...
let studioAlbums = 5
switch studioAlbums {
case 0...1:
    print("You're just starting out")
case 2...3:
    print("You're a rising star")
case 4...5:
    print("You're world famous!")
default:
    print("Have you done something new?")
}





// Extra functions
// External and internal parameter names

func countLettersInString(string: String) {
    print("The string \(string) has \(string.count) letters.")
}
countLettersInString(string: "Hello")

// Sometimes you want parameters to be named one way when a function is called, but another way inside the function itself.
// Swift’s solution is to let you specify one name for the parameter when it’s being called, and another inside the method. To use this, just write the parameter name twice – once for external, one for internal.
func countLettersInString(myString str: String) {
    print("The string \(str) has \(str.count) letters.")
}
countLettersInString(myString: "Hello")

// You can also specify an underscore, _, as the external parameter name, which tells Swift that it shouldn’t have any external name at all. For example:
func countLettersInString(_ str: String) {
    print("The string \(str) has \(str.count) letters.")
}
countLettersInString("Hello")





// Extra Optionals
func getHaterStatus(weather: String) -> String? {
    if weather == "sunny" {
        return nil
    } else {
        return "Hate"
    }
}

var status: String?
status = getHaterStatus(weather: "rainy")

// imagine a function like this
func takeHaterAction(status: String) {
    if status == "Hate" {
        print("Hating")
    }
}
// That takes a string and prints a message depending on its contents. This function takes a String value, and not a String? value – you can't pass in an optional here, it wants a real string, which means we can't call it using the status variable.

// Solution ONE: OPTIONAL UNWRAPPING
// It checks whether an optional has a value, and if so unwraps it into a non-optional type then runs a code block.
if let unwrappedStatus = status {
    // unwrappedStatus contains a non-optional value!
} else {
    // in case you want an else block, here you go...
}

// so...
if let haterStatus = getHaterStatus(weather: "rainy") {
    takeHaterAction(status: haterStatus)
}

// Solution TWO: FORCE UNWRAPPING OPTIONAL
func yearAlbumReleased(name: String) -> Int? {
    if name == "Taylor Swift" { return 2006 }
    if name == "Fearless" { return 2008 }
    if name == "Speak Now" { return 2010 }
    if name == "Red" { return 2012 }
    if name == "1989" { return 2014 }
    
    return nil
}

var year = yearAlbumReleased(name: "Red")

if year == nil {
    print("There was an error")
} else {
    print("It was released in \(year!)")
}

// Implicitly unwrapped optional
var example:String!
// An implicitly unwrapped optional might contain a value, or might not. But it does not need to be unwrapped before it is used. Swift won't check for you,
// 'example' might contain a string, or it might contain nil
// Swift lets you access the value directly without the unwrapping safety





// Optional Chaining
func albumReleased(year: Int) -> String? {
    
    switch year {
    case 2006: return "Taylor Swift"
    case 2008: return "Fearless"
    case 2010: return "Speak Now"
    case 2012: return "Red"
    case 2014: return "1989"
    default: return nil
    }
}

let album1 = albumReleased(year: 2006)?.uppercased()
print("The album is \(album1)")  // Note that 'album' is still an optional String--optional chaining does not change the type of 'album'

// Nil coalescing operator
// "Use value A if you can, but if value A is nil then use value B."
let album2 = albumReleased(year: 2006) ?? "unknown"
print("The album is \(album2)")
// That double question mark is the nil coalescing operator, and in this situation it means "if albumReleased() returned a value then put it into the album variable, but if albumReleased() returned nil then use 'unknown' instead."
// If you look in the results pane now, you'll see "The album is Taylor Swift" printed in there – no more optionals. This is because Swift can now be sure it will get a real value back, either because the function returned one or because you're providing "unknown". This in turn means you don't need to unwrap anything or risk crashes – you're guaranteed to have real data to work with, which makes your code safer and easier to work with.





// Enumerations
// It defines a new data type and defines the possible values it can hold.
// For example, we might say there are five kinds of weather: sun, cloud, rain, wind and snow. If we make this an enum, it means Swift will accept only those five values – anything else will trigger an error
enum WeatherType {
    case sun, cloud, rain, wind, snow
}
func getHaterStatus(weather: WeatherType) -> String? {
    if weather == WeatherType.sun {
        return nil
    } else {
        return "Hate"
    }
}

getHaterStatus(weather: WeatherType.cloud)
// line 1 gives our type a name, WeatherType. This is what you'll use in place of String or Int in your code. Line 2 defines the five possible cases our enum can be.
// Modified the getHaterStatus() so that it takes a WeatherType value. The conditional statement is also rewritten to compare against WeatherType.sun, which is our value.

// Some changes...
enum WeatherType2 {
    case sun
    case cloud2
    case rain
    case wind
    case snow
}

func getHaterStatus(weather: WeatherType2) -> String? {
    if weather == .sun {
        return nil
    }
    else {
        return "Hate"
    }
}

getHaterStatus(weather: .cloud2)
// First, each of the weather types are now on their own line. This might seem like a small change, and indeed in this example it is, but it becomes important soon. The second change was that I wrote if weather == .sun – I didn't need to spell out that I meant WeatherType.sun because Swift knows I am comparing against a WeatherType variable, so it's using type inference.

// Enums cooperated with switch/case...
enum WeatherType3 {
    case sun
    case cloud3
    case rain
    case wind
    case snow
}

func getHaterStatus(weather: WeatherType3) -> String? {
    switch weather {
    case .sun:
        return nil
    case .cloud3, .wind:
        return "dislike"
    case .rain:
        return "hate"
    default:
        return "screw you"
    }
}

// Enums with additional values
enum WeatherType4 {
    case sun
    case cloud
    case rain
    case wind(speed: Int)
    case snow
}
// Swift lets us add extra conditions to the switch/case block so that a case will match only if those conditions are true. This uses the let keyword to access the value inside a case, then the where keyword for pattern matching.
func getHaterStatus(weather: WeatherType4) -> String? {
    switch weather {
    case .sun:
        return nil
    case .wind(let speed) where speed < 10:
        return "meh"
    case .cloud, .wind:
        return "dislike"
    case .rain, .snow:
        return "hate"
    }
}

getHaterStatus(weather: WeatherType4.wind(speed: 5))

// Swift evaluates switch/case from top to bottom, and stops as soon as it finds a match. This means that if case .cloud, .wind: appears before case .wind(let speed) where speed < 10: then it will be executed instead – and the output changes.





// Structs
struct Person {
    
    var clothes: String
    var shoes: String
    
    func describe() {
        print("I like wearing \(clothes) with \(shoes)")
    }
}

// When you define a struct, Swift makes them very easy to create because it automatically generates what's called a memberwise initializer.
let taylor = Person(clothes: "T-shirts", shoes: "sneakers")
let other = Person(clothes: "short skirts", shoes: "high heels")

var taylorCopy = taylor
taylorCopy.shoes = "flip flops"

print(taylor)
print(taylorCopy)
// The copy has a different value to the original: changing one did not change the other.





// Classes
// Differences between classes and structures:
    // You don't get an automatic memberwise initializer for your classes; you need to write your own.
    // You can define a class as being based off another class, adding any new things you want.
    // When you create an instance of a class it’s called an object (not struct). If you copy that object, both copies point at the same data by default – change one, and the copy changes too.

// Initialisers
class Person2 {
    var clothes: String
    var shoes: String
    
    init(clothes: String, shoes: String) {
        self.clothes = clothes
        self.shoes = shoes
    }
}
// Important: Swift requires that all non-optional properties have a value by the end of the initializer, or by the time the initializer calls any other method – whichever comes first.

// Class inheritance
class Singer {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func sing() {
        print("La la la la")
    }
}

var taylor2 = Singer(name: "Taylor", age: 25)
taylor2.name
taylor2.age
taylor2.sing()

class CountrySinger: Singer {
    override func sing() {
        print("Trucks, guitars, and liquor")
    }
}

var taylor3 = CountrySinger(name: "Taylor", age: 25)
taylor3.sing()

// Now if we want to declare a new property in an inherited class...
// Since the parent class Singer does not have this new property we need to create a custom initializer for the subclass that accepts a parameter for the new property.
// That new initializer also needs to take in the original properties of the parent class, so it can pass it onto the superclass.
// Passing on data to the superclass is done through a method call, and you can't make method calls in initializers until you have given all your properties values.
// So, we need to set the new property first, then pass on the other parameters for the superclass to use.
class HeavyMetalSinger: Singer {
    
    var noiseLevel: Int
    
    init(name: String, age: Int, noiseLevel: Int) {
        self.noiseLevel = noiseLevel
        super.init(name: name, age: age)
    
    }
    override func sing() {
        print("Grrrrr rargh rargh rarrrrgh!")
    }
}
// Notice how its initializer takes three parameters, then calls super.init() to pass name and age on to the Singer superclass - but only after its own property has been set.

// Values vs References
// Swift calls structs "value types" because they just point at a value, and classes "reference types" because objects are just shared references to the real value.
// If you want to have one shared state that gets passed around and modified in place, you're looking for classes. You can pass them into functions or store them in arrays, modify them in there, and have that change reflected in the rest of your program.
// If you want to avoid shared state where one copy can't affect all the others, you're looking for structs. You can pass them into functions or store them in arrays, modify them in there, and they won't change wherever else they are referenced.





// Properties
// Property observers
// Swift lets you add code to be run when a property is about to be changed or has been changed. This is frequently a good way to have a user interface update when a value changes.
// There are two kinds of property observer: willSet and didSet, and they are called before or after a property is changed. In willSet Swift provides your code with a special value called newValue that contains what the new property value is going to be, and in didSet you are given oldValue to represent the previous value.
struct Person3 {
    
    var clothes: String {
        willSet {
            updateUI(msg: "I'm changing from \(clothes) to \(newValue)")
        }
        
        didSet {
            updateUI(msg: "I just changed from \(oldValue) to \(clothes)")
        }
    }
    
}

func updateUI(msg: String) {
    print(msg)
}

var taylor4 = Person3(clothes: "T-shirts")
taylor4.clothes = "short skirts"

// Computed properties
// Those are the properties that get initialised automatically, without the need to initialise it during struct creation i.e. no need for brackets after struct name
// To make a computed property, place an open brace after your property then use either get or set to make an action happen at the appropriate time. For example, if we wanted to add a ageInDogYears property that automatically returned a person's age multiplied by seven, we'd do this:
struct Person4 {
    
    var age: Int
    
    var ageInDogYears: Int {
        get {
            return age * 7
        }
    }
    
}
var fan = Person4(age: 25)
print(fan.ageInDogYears)





// Static properties and methods
// Swift lets you create properties and methods that belong to a type, rather than to instances of a type. This is helpful for organizing your data meaningfully by storing shared data.
struct TaylorFan {
    
    static var favoriteSong = "Look What You Made Me Do"
    
    var name: String
    var age: Int
    
}
let fan2 = TaylorFan(name: "James", age: 25)
print(TaylorFan.favoriteSong)
// So, a Taylor Swift fan has a name and age that belongs to them, but they all have the same favorite song.
// Because static methods belong to the struct itself rather than to instances of that struct, you can't use it to access any non-static properties from the struct.





// Access control
// Access control lets you specify what data inside structs and classes should be exposed to the outside world, and you get to choose four modifiers:
// Public: this means everyone can read and write the property.
// Internal: this means only your Swift code can read and write the property. If you ship your code as a framework for others to use, they won’t be able to read the property.
// File Private: this means that only Swift code in the same file as the type can read and write the property.
// Private: this is the most restrictive option, and means the property is available only inside methods that belong to the type, or its extensions.

// Sometimes you'll want to explicitly set a property to be private because it stops others from accessing it directly. This is useful because your own methods can work with that property, but others can't, thus forcing them to go through your code to perform certain actions.
class TaylorFan2 {
    private var name: String?
}





// Polymorphism and typecasting
// Because classes can inherit from each other, it means one class is effectively a superset of another: class B has all the things A has, with a few extras. This in turn means that you can treat B as type B or as type A, depending on your needs.
class Album {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func getPerformance() -> String {
        return "The album \(name) sold lots"
    }
}

class StudioAlbum: Album {
    var studio: String
    
    init(name: String, studio: String) {
        self.studio = studio
        super.init(name: name)
    }
    
    override func getPerformance() -> String {
        return "The studio album \(name) sold lots"
    }
}

class LiveAlbum: Album {
    var location: String
    
    init(name: String, location: String) {
        self.location = location
        super.init(name: name)
    }
    
    override func getPerformance() -> String {
        return "The live album \(name) sold lots"
    }
}

var taylorSwift = StudioAlbum(name: "Taylor Swift", studio: "The Castles Studios")
var fearless = StudioAlbum(name: "Speak Now", studio: "Aimeeland Studio")
var iTunesLive = LiveAlbum(name: "iTunes Live from SoHo", location: "New York")

// Polymorphing...
var allAlbums: [Album] = [taylorSwift, fearless, iTunesLive]

for album in allAlbums {
    print(album.getPerformance())
}
// That's polymorphism in action: an object can work as its class and its parent classes, all at the same time.

// Coverting types with typecasting
// In the album loop, if you try to write something like print(album.studio) it will refuse to build because only StudioAlbum objects have that property (Album doesn't).
// So you can use either as? or as!
for album in allAlbums {
    let studioAlbum = album as? StudioAlbum
}
// The conversion might have worked, in which case you have a studio album you can work with, or it might have failed, in which case you have nil.

// Adding if let statement...
for album in allAlbums {
    print(album.getPerformance())
    
    if let studioAlbum = album as? StudioAlbum {
        print(studioAlbum.studio)
    }
    else if let liveAlbum = album as? LiveAlbum {
        print(liveAlbum.location)
    }
}

// now as!...
var allAlbums2: [Album] = [taylorSwift, fearless]

for album in allAlbums2 {
    let studioAlbum = album as! StudioAlbum
    print(studioAlbum.studio)
}

// Swift also lets you downcast as part of the array loop, which in this case would be more efficient.
for album in allAlbums2 as! [StudioAlbum] {
    print(album.studio)
}
// All items in the array have to be StudioAlbums!

// Swift also allows optional downcasting at the array level, although it's a bit more tricksy because you need to use the nil coalescing operator to ensure there's always a value for the loop.
for album in allAlbums2 as? [LiveAlbum] ?? [LiveAlbum]() {
    print(album.location)
}
// “try to convert allAlbums to be an array of LiveAlbum objects, but if that fails just create an empty array of live albums and use that instead” – i.e., do nothing





// Closures
// A closure can be thought of as a variable that holds code. So, where an integer holds 0 or 500, a closure holds lines of Swift code. Closures also capture the environment where they are created, which means they take a copy of the values that are used inside them.
let vw = UIView()

UIView.animate(withDuration: 0.5, animations: {
    vw.alpha = 0
})
// Note: I declared the vw constant outside of the closure, then used it inside. Swift detects this, and makes that data available inside the closure too.

// Trailing closures
// Rule: if the last parameter to a method takes a closure, you can eliminate that parameter and instead provide it as a block of code inside braces.
UIView.animate(withDuration: 0.5) {
    vw.alpha = 0
}





// Protocols
// They define a set of methods and properties that a type must implement if it says it conforms to the protocol. This contract gives us the flexibility to use different types to solve the same problem – we don’t get whether a ThingA or a ThingB is being used, as long as they both conform to the Thing protocol.

protocol Employee {
    var name: String { get set }
    var jobTitle: String { get set }
    func doWork()
}
// Things to note:
// 1. Both the properties have { get set } after them. This means that conforming types must make them both gettable (readable) and settable (writeable), which in turn means if a type says it is compatible with the Employee protocol it must make those two properties variables rather than constants.
// 2. DoWork() has no code inside it. Protocols are contracts defining how something ought to be able to behave, and don’t provide implementations of those behaviors.
// 3. The protocol itself isn’t a type, which means we can’t create instances of it.

struct Executive: Employee {
    
    var name = "Steve Jobs"
    var jobTitle = "CEO"
    func doWork() {
        print("I'm strategizing!")
    }
}

struct Manager: Employee {
    
    var name = "Maurice Moss"
    var jobTitle = "Head of IT"
    func doWork() {
        print("I'm turning it off and on again.")
    }
}

let staff: [Employee] = [Executive(), Manager()]

for person in staff {
    person.doWork()
}
// Because both types conform to Employee – they implement the properties and methods of that protocol – we can create an employee array and use the objects inside that array without know what their actual type is.





// Extensions
var myInt = 0
extension Int {
    func plusOne() -> Int {
        return self + 1
    }
}
myInt.plusOne()
// extension Int tells Swift that we want to add functionality to its Int struct. We could have used String, Array, or whatever instead, but Int is a nice easy one to start.

// The extension has been added to all integers, so you can even call it like this:
5.plusOne()

// Our extension adds 1 to its input number and returns it to the caller, but doesn't modify the original value
var myInt2 = 10
myInt2.plusOne()
myInt2

// To push things a little further, let's modify the plusOne() method so that it doesn't return anything, instead modifying the instance itself – i.e., the input integer.
// However if you do this:
extension Int {
    func plusOne2() {
        //self += 1
    }
}
// It will not work. The reason is that we could call plusOne() using 5.plusOne(), and clearly you can't modify the number 5 to mean something else.
// So, Swift forces you to declare the method mutating, meaning that it will change its input. Change your extension to this:
extension Int {
    mutating func plusOne3() {
        self += 1
    }
}
// Once you have declared a method as being mutating, Swift knows it will change values so it won't let you use it with constants. For example:
var myInt3 = 10
myInt3.plusOne3()
let otherInt = 10
//otherInt.plusOne3()
// The first integer will be modified correctly, but the second will fail because Swift won't let you modify constants.

// Quick tip: If you want to get rid of white spaces in strings, there are two ways:
// 1:
// str = str.trimmingCharacters(in: .whitespacesAndNewlines)
// 2:
extension String {
    mutating func trim() {
        self = trimmingCharacters(in: .whitespacesAndNewlines)
    }
}





// Protocol extensions
// Protocol extensions let us define implementations of things inside the protocol, adding the functionality to all types that conform to the protocol in a single place.

// To demonstrate how this works, let’s look at another simple extension for the Int data type: we’re going to add a clamp() method that makes sure one number falls within the lower and upper bounds that are specified:
extension Int {
    func clamp(low: Int, high: Int) -> Int {
        if (self > high) {
            // if we are higher than the upper bound, return the upper bound
            return high
        } else if (self < low) {
            // if we are lower than the lower bound, return the lower bound
            return low }
        // we are inside the range, so return our value
        return self
    }
    
}
let i: Int = 8
print(i.clamp(low: 0, high: 5))
// I explicitly made i an Int for a reason: there are other kinds of integers available in Swift. For example, UInt is an unsigned integer, which means it sacrifices the ability to hold negative numbers in exchange for the ability to hold much larger positive numbers.
// And Int8 holds an integer made up of 8 binary digits, which holds a maximum value of 127, and UInt64 is the largest type of integer

// Our extension modifies the Int data type specifically, rather than all variations of integers, which means code like this won’t work because UInt64 doesn’t have the extension:
let j: UInt64 = 8
//print(j.clamp(low: 0, high: 5))

// Solution: create protocol extensions: extensions that modify several data types at once.

// self means “my current value” and Self means “my current data type.”

// Say if we want the clamp() method to apply to all types of integer, we cannot make it Int--use Self instead:
extension BinaryInteger {
    func clamp(low: Self, high: Self) -> Self {
        if (self > high) {
            return high
        } else if (self < low) {
            return low
        }
        return self
    }
    
}
// BinaryInteger is a protocol that all of Swift’s integer types conform to. This means all integer types get access to the clamp() method, and work as expected – we don’t need to extend them all individually.

// Protocol extensions are helpful for providing default method implementations so that conforming types don’t need to implement those methods themselves unless they specifically want to.

// Another example: we might define an extension for our Employee protocol so that all conforming types automatically get a doWork() method:
extension Employee {
    func doWork() {
        print("I'm busy!")
    }
}
