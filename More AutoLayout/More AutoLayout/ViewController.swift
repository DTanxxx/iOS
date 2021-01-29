//
//  ViewController.swift
//  More AutoLayout
//
//  Created by David Tan on 10/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        // By default iOS generates Auto Layout constraints for you based on a view's size and position. We'll be doing it by hand, so we need to disable this feature.
        label1.backgroundColor = UIColor.red
        label1.text = "THESE"
        label1.sizeToFit()
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = UIColor.cyan
        label2.text = "ARE"
        label2.sizeToFit()
        
        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = UIColor.yellow
        label3.text = "SOME"
        label3.sizeToFit()
        
        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = UIColor.green
        label4.text = "AWESOME"
        label4.sizeToFit()
        
        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.backgroundColor = UIColor.orange
        label5.text = "LABELS"
        label5.sizeToFit()
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        // All five views then get added to the view belonging to our view controller.
        
        // MARK: - Adding basic constraints
        
        let viewsDictionary = ["label1": label1, "label2": label2,
        "label3": label3, "label4": label4, "label5": label5]
        // Strings for its keys and our labels as its values
        
        /*for label in viewsDictionary.keys {
            view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
        }*/
        // view.addConstraints() adds an array of constraints to our view controller's view. This array is used rather than a single constraint because VFL can generate multiple constraints at a time.
        // NSLayoutConstraint.constraints(withVisualFormat:) is the Auto Layout method that converts VFL into an array of constraints.
        // The parameters options and metrics can be used to customize the meaning of the VFL.
        
        // Now let's look at the Visual Format Language itself: "H:|[label1]|"
        // It is a string that describes how we want the layout to look. This VFL gets converted into Auto Layout constraints, then added to the view.
        // 1. The H: parts means that we're defining a horizontal layout.
        // 2. The pipe symbol, |, means "the edge of the view." We're adding these constraints to the main view inside our view controller, so this effectively means "the edge of the view controller."
        // 3. Finally, we have [label1], which is a visual way of saying "put label1 here". Imagine the brackets, [ and ], are the edges of the view.
        // So, "H:|[label1]|" means "horizontally, I want my label1 to go edge to edge in my view", and effectively what happens is that each of the labels stretch edge-to-edge in the view.
        
        /*view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1]-[label2]-[label3]-[label4]-[label5]", options: [], metrics: nil, views: viewsDictionary))*/
        // V: meaning that these constraints are vertical.
        // '-' symbol, which means "space". It's 10 points by default, but you can customize it.
        // This vertical VFL doesn't have a pipe at the end, so we're not forcing the last label to stretch all the way to the edge of our view. This will leave whitespace after the last label, which is what we want right now.
        
        // MARK: - Adding advanced constraints
        
        /*view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(==88)]-[label2(==88)]-[label3(==88)]-[label4(==88)]-[label5(==88)]-(>=10)-|", options: [], metrics:nil, views: viewsDictionary))*/
        // Now we want the bottom of our last label must be at least 10 points away from the bottom of the view controller's view, and each of the five labels to be 88 points high.
        // Note that when specifying the size of a space, you need to use the - before and after the size: a simple space, -, becomes -(>=10)-.
        
        // Or easier, I can use metrics:
        /*let metrics = ["labelHeight": 88]
        view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight)]-[label2(labelHeight)]-[label3(labelHeight)]-[label4(labelHeight)]-[label5(labelHeight)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))*/
        
        // This however does not adjust when the view is the landscape mode, therefore we resolve this by setting a lower priority for label1, so that the view and try to fit all the labels by squashing label1.
        // Squashing is fine, but we want the labels to be squashed all equally, therefore we set the height of other labels to that of label1:
        /*let metrics = ["labelHeight": 88]
        view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))*/
        // The @999 assigns priority to a given constraint, and using (label1) for the sizes of the other labels is what tells Auto Layout to make them the same height.
        
        // MARK: - Time for Anchors - an easier way to set constraints
        
        /*for label in [label1, label2, label3, label4, label5] {
            label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 88).isActive = true
        }*/
        // This set the labels to have the same width as our main view, and to have a height of exactly 88 points.
        
        // We haven’t set top anchors, though, so the layout won’t look correct just yet. What we want is for the top anchor for each label to be equal to the bottom anchor of the previous label in the loop. Of course, the first time the loop goes around there is no previous label, so we can model that using optionals:
        var previous: UILabel?
        
        // The first time the loop goes around that will be nil, but then we’ll set it to the current item in the loop so the next label can refer to it. If previous is not nil, we’ll set a topAnchor constraint.
        for label in [label1, label2, label3, label4, label5] {
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2, constant: -10).isActive = true
            // Note: for some challenges in the book, try to look for an existing method that does the thing, inside the scroll view of available functions, instead of trying to write new code of your own.
            
            if let previous = previous {
                // We have a previous label - create a height constraint
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
            }
            else {
                // Set the safe area (the space that’s actually visible inside the insets of the iPhone X and other such devices).
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            }
            
            // Set the previous label to be the current one, for the next loop iteration
            previous = label
        }
        
        
    }


}

