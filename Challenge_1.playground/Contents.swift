import UIKit

func fizzbuzz(number:Int) -> String {
    
    if number % 3 == 0 && number % 5 == 0 {
        return "Fizz Buzz"
    }
    else if number % 3 == 0 {
        return "Fizz"
    }
    else if number % 5 == 0 {
        return "Buzz"
    }
    else {
        return String(number)
    }
}

fizzbuzz(number: 3)
fizzbuzz(number: 5)
fizzbuzz(number: 15)
fizzbuzz(number: 16)


