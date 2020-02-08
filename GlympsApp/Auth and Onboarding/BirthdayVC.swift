//
//  BirthdayVC.swift
//  Glymps
//
//  Created by James B Morris on 5/7/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

// view controller to set up new user birth date during onboarding
class BirthdayVC: UIViewController {
    
    @IBOutlet weak var monthTextfield: UITextField!
    
    @IBOutlet weak var dayTextfield: UITextField!
    
    @IBOutlet weak var yearTextfield: UITextField!
    
    @IBOutlet weak var underageLabel: UILabel!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var userEmail = ""
    var userPassword = ""
    var userName = ""
    
    var currentMonth: Int?
    var currentDay: Int?
    var currentYear: Int?
    
    var userAge: Int?
    var validAge: Bool?
    
    // pickers to pick month/day/year
    let picker1 = UIPickerView()
    let picker2 = UIPickerView()
    let picker3 = UIPickerView()
    
    let months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    
    let days = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    
    let years = ["2019", "2018", "2017", "2016", "2015", "2014", "2013", "2012", "2011", "2010", "2009", "2008", "2007", "2006", "2005", "2004", "2003", "2002", "2001", "2000", "1999", "1998", "1997", "1996", "1995", "1994", "1993", "1992", "1991", "1990", "1989", "1988", "1987", "1986", "1985", "1984", "1983", "1982", "1981", "1980", "1979", "1978", "1977", "1976", "1975", "1974", "1973", "1972", "1971", "1970", "1969", "1968", "1967", "1966", "1965", "1964", "1963", "1962", "1961", "1960", "1959", "1958", "1957", "1956", "1955", "1954", "1953", "1952", "1951", "1950", "1949", "1948", "1947", "1946", "1945", "1944", "1943", "1942", "1941", "1940", "1939", "1938", "1937", "1936", "1935", "1934", "1933", "1932", "1931", "1930", "1929", "1928", "1927", "1926", "1925"]

    // setup pickers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthTextfield.delegate = self
        dayTextfield.delegate = self
        yearTextfield.delegate = self
        
        monthTextfield.tag = 0
        dayTextfield.tag = 1
        yearTextfield.tag = 2
        
        monthTextfield.attributedPlaceholder = NSAttributedString(string: "MM", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        dayTextfield.attributedPlaceholder = NSAttributedString(string: "DD", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        yearTextfield.attributedPlaceholder = NSAttributedString(string: "YYYY", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        let date = Date()
        let calendar = Calendar.current
        currentYear = calendar.component(.year, from: date)
        currentDay = calendar.component(.day, from: date)
        currentMonth = calendar.component(.month, from: date)
        
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(BirthdayVC.keyboardDismiss))
        view.addGestureRecognizer(dismissKeyboard)
        
        createPicker()
        createToolbar()
        
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
        nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        nextBtn.layer.borderWidth = 1
    }
    
    // layout pickers, depending if they are for month, day, or year
    func createPicker() {
        
        picker1.delegate = self
        picker2.delegate = self
        picker3.delegate = self
        
        monthTextfield.inputView = picker1
        dayTextfield.inputView = picker2
        yearTextfield.inputView = picker3
        
        picker1.backgroundColor = .white
        picker2.backgroundColor = .white
        picker3.backgroundColor = .white
    }
    
    // create "done" toolbar so user can dismiss picker
    func createToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        toolbar.barTintColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        toolbar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(BirthdayVC.keyboardDismiss))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        monthTextfield.inputAccessoryView = toolbar
        dayTextfield.inputAccessoryView = toolbar
        yearTextfield.inputAccessoryView = toolbar
    }
    
    // listener for textfield editing tracker
    @objc func textFieldDidChange() {
        
        guard let month = monthTextfield.text, !month.isEmpty, let day = dayTextfield.text, !day.isEmpty, let year = yearTextfield.text, !year.isEmpty, let birthMonth = Int(monthTextfield.text!), let birthDay = Int(dayTextfield.text!), let birthYear = Int(yearTextfield.text!) else {
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.isEnabled = false
            return
        }
        if birthMonth < currentMonth! || (birthMonth == currentMonth && birthDay < currentDay!) {
            userAge = currentYear! - birthYear
        } else {
            userAge = currentYear! - birthYear - 1
        }
        
        if userAge! >= 18 {
            validAge = true
            underageLabel.isHidden = true
            nextBtn.setTitleColor(#colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            nextBtn.isEnabled = true
        } else {
            validAge = false
            underageLabel.isHidden = false
            nextBtn.setTitleColor(#colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1), for: .normal)
            nextBtn.layer.borderColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.isEnabled = false
        }
    }
    
    // dismiss keyboard
    @objc func keyboardDismiss() {
        
        textFieldDidChange()
        view.endEditing(true)
    }
    
    // prep data for segue to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! GenderVC
        destination.userEmail = userEmail
        destination.userPassword = userPassword
        destination.userName = userName
        destination.userAge = userAge!
    }
    
    // move to next view controller
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)

        if userAge != nil {
            performSegue(withIdentifier: "birthdayToGender", sender: self)
        }
    }
    

}

// go to next textfield

extension BirthdayVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
}

// setup picker for birthday
extension BirthdayVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of sections in row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows: Int?
        if pickerView == picker1 {
            rows = months.count
        }
        if pickerView == picker2 {
            rows = days.count
        }
        if pickerView == picker3 {
            rows = years.count
        }
        return rows!
    }
    
    // title (month, day, or year)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title: String?
        
        if pickerView == picker1 {
            title = months[row]
        }else if pickerView == picker2 {
            title = days[row]
        }else if pickerView == picker3 {
            title = years[row]
        }
        return title!
    }
    
    // attach date to display view above if month/day/year selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var selectedPersona: String?
        
        if pickerView == picker1 {
            selectedPersona = months[row]
            monthTextfield.text = selectedPersona
            textFieldDidChange()
        }
        if pickerView == picker2 {
            selectedPersona = days[row]
            dayTextfield.text = selectedPersona
            textFieldDidChange()
        }
        if pickerView == picker3 {
            selectedPersona = years[row]
            yearTextfield.text = selectedPersona
            textFieldDidChange()
        }
    }
    
    // allocate selected month/day/year to appropriate display view above
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        
        if pickerView == picker1 {
            if monthTextfield.text == "MM" {
                monthTextfield.text = months[0]
            }
            
            if let view = view as? UILabel {
                label = view
            } else {
                label = UILabel()
            }
            
            label.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Next", size: 17)
            
            label.text = months[row]
            
        }else if pickerView == picker2 {
            if dayTextfield.text == "DD" {
                dayTextfield.text = days[0]
            }
            
            if let view = view as? UILabel {
                label = view
            } else {
                label = UILabel()
            }
            
            label.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Next", size: 17)
            
            label.text = days[row]
            
        } else if pickerView == picker3 {
            if yearTextfield.text == "YYYY" {
                yearTextfield.text = years[0]
            }
            
            if let view = view as? UILabel {
                label = view
            } else {
                label = UILabel()
            }
            
            label.textColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Next", size: 17)
            
            label.text = years[row]
            
        }
            return label
    }
}
