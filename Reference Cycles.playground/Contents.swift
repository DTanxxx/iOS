import UIKit

// Automatic Reference Counting
// First of all, the purpose of this whole thing is to save memory and to prevent memory leak by deallocating stuff that are not needed.

// A short Intro...
class Person {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    deinit {
        print("\(name) is being deinitialized")
    }
}

var reference1: Person?
var reference2: Person?
var reference3: Person?
// The use of optionals here allows us to set them to nil later on when we want to deallocated them. The optionals also tell us that the 'reference' variables are not currently referencing to the Person instance, instead it is set to nil for now.

reference1 = Person(name: "John Appleseed")
// Prints "John Appleseed is being initialized"

// There is now a strong reference from reference1 to the new Person instance. Because there is at least one strong reference, ARC makes sure that this Person is kept in memory and is not deallocated.
//If you assign the same Person instance to two more variables, two more strong references to that instance are established:

reference2 = reference1
reference3 = reference1
// There are now three strong references to this single Person instance.

// If you break two of these strong references (including the original reference) by assigning nil to two of the variables, a single strong reference remains, and the Person instance is not deallocated:
reference1 = nil
reference2 = nil

// However now...
reference3 = nil
// Prints "John Appleseed is being deinitialized"

// ================================================================================================================================

// Strong Reference Cycles Between Class Instances
// Now the things get interesting...

class Person2 {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment2?
    deinit { print("\(name) is being deinitialized") }
}

class Apartment2 {
    let unit: String
    init(unit: String) { self.unit = unit }
    var tenant: Person2?
    deinit { print("Apartment \(unit) is being deinitialized") }
}

// Every Person2 instance has a name property of type String and an optional apartment property that is initially nil. The apartment property is optional, because a person may not always have an apartment.
// Similarly, every Apartment2 instance has a unit property of type String and has an optional tenant property that is initially nil. The tenant property is optional because an apartment may not always have a tenant.

var john: Person2?
var unit4A: Apartment2?

john = Person2(name: "John Appleseed")
unit4A = Apartment2(unit: "4A")

// At this point, the Person2 instance and Apartment2 instance each has got one strong reference, from their respective assigned variables.

// You can now link the two instances together so that the person has an apartment, and the apartment has a tenant. Note that an exclamation mark (!) is used to unwrap and access the instances stored inside the john and unit4A optional variables, so that the properties of those instances can be set:
john!.apartment = unit4A
unit4A!.tenant = john

// At this point, the Person2 instance and Apartment2 instance each has got two strong references, one from the respective variables, and the other from each other's property (as a result of above code).

// Now if I do this:
john = nil
unit4A = nil
// deinit will not be called because the strong reference due to the class property still remains (which cannot be broken through code). This is called the Strong Reference Cycle, which uses up unnecessary memories.

// ================================================================================================================================

// Now that you have seen the problem, there is a way to resolve it.
// You do that by resolving the strong reference cycle in two ways:

// 1. Weak reference
// Use a weak reference when the other instance has a shorter lifetime—that is, when the other instance can be deallocated first. In the Apartment example above, it’s appropriate for an apartment to be able to have no tenant at some point in its lifetime, and so a weak reference is an appropriate way to break the reference cycle in this case.

// You indicate a weak reference by placing the weak keyword before a property or variable declaration.

// Because a weak reference does not keep a strong hold on the instance it refers to, it’s possible for that instance to be deallocated while the weak reference is still referring to it. Therefore, ARC automatically sets a weak reference to nil when the instance that it refers to is deallocated.
// And, because weak references need to allow their value to be changed to nil at runtime, they are always declared as variables, rather than constants, of an optional type.
// You can check for the existence of a value in the weak reference, just like any other optional value, and you will never end up with a reference to an invalid instance that no longer exists.

// NOTE: Property observers aren’t called when ARC sets a weak reference to nil.

class Person3 {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment3?
    deinit { print("\(name) is being deinitialized") }
}

class Apartment3 {
    let unit: String
    init(unit: String) { self.unit = unit }
    weak var tenant: Person3?
    // note the 'weak' keyword
    deinit { print("Apartment \(unit) is being deinitialized") }
}

var john2: Person3?
var unit4A2: Apartment3?

john2 = Person3(name: "John Appleseed")
unit4A2 = Apartment3(unit: "4A")

john2!.apartment = unit4A2
unit4A2!.tenant = john2

// This time, there are still two strong references pointing to the Apartment3 instance, however there is only one strong reference pointing to the Person3 instance, which is from the john2 variable.
// Person3 instance is instead referred to by another weak reference, from unit4A2!.apartment

// Therefore if I do this:
john = nil
// It will print "John Appleseed is being deinitialized", because the only strong reference to the Person3 instance is broken, therefore ARC deallocate it to save memory. This also means that the Apartment3 instance has lost the strong reference from Person3 instance.

// So at this point, the Person3 instance is completely deallocated, and Apartment3 instance has only got one strong reference which is from unit4A2 variable.

// If we do this:
unit4A = nil
// Prints "Apartment 4A is being deinitialized"

// BOOM! Everything is deallocated! Case solved.

// ================================================================================================================================

// 2. Unowned reference
// An unowned reference is used when the other instance has the same lifetime or a longer lifetime. You indicate an unowned reference by placing the unowned keyword before a property or variable declaration.
// An unowned reference is expected to always have a value. As a result, ARC never sets an unowned reference’s value to nil, which means that unowned references are defined using non-optional types.
// Use an unowned reference only when you are sure that the reference always refers to an instance that has not been deallocated.
// If you try to access the value of an unowned reference after that instance has been deallocated, you’ll get a runtime error.

class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit { print("\(name) is being deinitialized") }
}
 
class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit { print("Card #\(number) is being deinitialized") }
}

// The relationship between Customer and CreditCard is slightly different from the relationship between Apartment and Person seen in the weak reference example above. In this data model, a customer may or may not have a credit card, but a credit card will always be associated with a customer.
// A CreditCard instance never outlives the Customer that it refers to. To represent this, the Customer class has an optional card property, but the CreditCard class has an unowned (and non-optional) customer property.
// Because a credit card will always have a customer, you define its customer property as an unowned reference, to avoid a strong reference cycle.

var john3: Customer?

john3 = Customer(name: "John Appleseed")
john3!.card = CreditCard(number: 1234_5678_9012_3456, customer: john3!)

// Now, there is one strong reference pointing to Customer instance (from john3), and an unowned reference pointing to Customer instance from CreditCard instance's customer property. There is also a strong reference from Customer instance's card property to the CreditCard instance.

// If you break the strong reference held by the john3 variable, there are no more strong references holding the Customer instance and therefore it is deallocated. Once that is deallocated, the only strong reference holding CreditCard instance will be broken too. Hence, everything is deallocated; case solved!

john = nil
// Prints "John Appleseed is being deinitialized"
// Prints "Card #1234567890123456 is being deinitialized"

// ================================================================================================================================

// Conclusion:
// The Person and Apartment example shows a situation where two properties, both of which are allowed to be nil, have the potential to cause a strong reference cycle. This scenario is best resolved with a weak reference.
// The Customer and CreditCard example shows a situation where one property that is allowed to be nil and another property that cannot be nil have the potential to cause a strong reference cycle. This scenario is best resolved with an unowned reference.

// However, there is a third scenario, in which both properties should always have a value, and neither property should ever be nil once initialization is complete. In this scenario, it’s useful to combine an unowned property on one class with an implicitly unwrapped optional property on the other class.
// This enables both properties to be accessed directly (without optional unwrapping) once initialization is complete, while still avoiding a reference cycle.

class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}

class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}

// This example defines two classes, Country and City, each of which stores an instance of the other class as a property. In this data model, every country must always have a capital city, and every city must always belong to a country. To represent this, the Country class has a capitalCity property, and the City class has a country property.

// The initializer for City is called from within the initializer for Country. However, the initializer for Country cannot pass self to the City initializer until a new Country instance is fully initialized.
// To cope with this requirement, you declare the capitalCity property of Country as an implicitly unwrapped optional property, indicated by the exclamation mark at the end of its type annotation (City!). This means that the capitalCity property has a default value of nil.
// Yes I see the cheeky capitalCity=nil here, but it would not affect the ultimate goal, which is to have a country in City and a capitalCity in Country.
// Anyways, because capitalCity has a default nil value, a new Country instance is considered fully initialized as soon as the Country instance sets its name property within its initializer. This means that the Country initializer can start to reference and pass around the implicit self property as soon as the name property is set.
// The Country initializer can therefore pass self as one of the parameters for the City initializer when the Country initializer is setting its own capitalCity property.

// All of this means that you can create the Country and City instances in a single statement, WITHOUT creating a strong reference cycle, and the capitalCity property can be accessed directly, without needing to use an exclamation mark to unwrap its optional value.
var country = Country(name: "Canada", capitalName: "Ottawa")
print("\(country.name)'s capital city is called \(country.capitalCity.name)")
// Prints "Canada's capital city is called Ottawa"

// In the example above, the use of an implicitly unwrapped optional means that all of the two-phase class initializer requirements are satisfied. The capitalCity property can be used and accessed like a non-optional value once initialization is complete, while still avoiding a strong reference cycle.

// ================================================================================================================================

// Strong Reference Cycles for Closures
// A strong reference cycle can also occur if you assign a closure to a property of a class instance, and the body of that closure captures the instance. This capture might occur because the closure’s body accesses a property of the instance, such as self.someProperty, or because the closure calls a method on the instance, such as self.someMethod(). In either case, these accesses cause the closure to “capture” self, creating a strong reference cycle.
// This strong reference cycle occurs because closures, like classes, are reference types. When you assign a closure to a property, you are assigning a reference to that closure. In essence, it’s the same problem as above—two strong references are keeping each other alive. However, rather than two class instances, this time it’s a class instance and a closure that are keeping each other alive.

class HTMLElement {

    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }
    // This lazy property references a closure that combines name and text into an HTML string fragment. The asHTML property is of type () -> String, or “a function that takes no parameters, and returns a String value”.
    // By default, the asHTML property is assigned a closure that returns a string representation of an HTML tag (text of the tag is optional).

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinitialized")
    }

}
let heading = HTMLElement(name: "h1")
let defaultText = "some default text"
heading.asHTML = {
    return "<\(heading.name)>\(heading.text ?? defaultText)</\(heading.name)>"
}  // the asHTML property is named and used somewhat like an instance method. However, because asHTML is a closure property rather than an instance method, you can replace the default value of the asHTML property with a custom closure
print(heading.asHTML())
// Prints "<h1>some default text</h1>"

// The asHTML property is declared as a lazy property, because it’s only needed if and when the element actually needs to be rendered as a string value for some HTML output target. The fact that asHTML is a lazy property means that you can refer to self within the default closure, because the lazy property will not be accessed until after initialization has been completed and self is known to exist.

// Create an instance of HTMLElement...
var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML)
// Prints "<p>hello, world</p>"

// Unfortunately, the HTMLElement class creates a strong reference cycle between an HTMLElement instance and the closure used for its default asHTML value.
// The instance’s asHTML property holds a strong reference to its closure. However, because the closure refers to self within its body (as a way to reference self.name and self.text), the closure captures self, which means that it holds a strong reference back to the HTMLElement instance. A strong reference cycle is created between the two.
// Note that even though the closure refers to self multiple times, it only captures one strong reference to the HTMLElement instance.

// If you set paragraph variable to nil and break its strong reference to the HTMLElement instance, neither the HTMLElement instance nor its closure are deallocated, because of the strong reference cycle.
paragraph = nil
// the message in the HTMLElement deinitializer is not printed

// =========================================================================================================================================================

// Resolving Strong Reference Cycles for Closures
// You resolve a strong reference cycle between a closure and a class instance by defining a capture list as part of the closure’s definition. A capture list defines the rules to use when capturing one or more reference types within the closure’s body. As with strong reference cycles between two class instances, you declare each captured reference to be a weak or unowned reference rather than a strong reference.

// Defining a Capture List
