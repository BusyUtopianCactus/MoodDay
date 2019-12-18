//
//  ViewController.swift
//  FirstAppNoSwiftUI
//
//  Created by Daniel Basman on 12/16/19.
//  Copyright © 2019 Daniel Basman. All rights reserved.
//

import UIKit
import Charts
import EventKit

class ViewController: UIViewController {

    var eventStore:EKEventStore!
    //MARK: Properties
    var goals = [0, 0]
    let players = ["Good", "Bad"]
    var badCounter = 0.0
    var goodCounter = 0.0
    var compareGoodCount = 0.0
    var compareBadCount = 0.0
    var lastClick:String = ""
    
  
  
    @IBOutlet weak var UndoButton: UIButton!
    @IBOutlet weak var RefreshButton: UIButton!
    @IBOutlet weak var InstructionView: UIView!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var InstructionLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var MainLabel: UILabel!
    @IBOutlet weak var BadButton: UIButton!
    @IBOutlet weak var GoodButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventStore = EKEventStore.init()
        eventStore.requestAccess(to: .event, completion: {(granted, error) in
            if(granted) {
                print("Granted \(granted)")
            } else {
                print("error \(String(describing: error))")
            }
        })
        //print(fetchEvents())
        
        
        BottomView.bringSubviewToFront(InstructionView)
        InstructionView.bringSubviewToFront(InstructionLabel)
        BottomView.sendSubviewToBack(pieChart)
        // Do any additional setup after loading the view.
        if (InstructionLabel.isHidden == true) {
            
            customizeChart(dataPoints: players, values: goals.map{ Double($0) })
        }
                
    }

    //MARK: Actions
    
    @IBAction func RefreshPage(_ sender: UIButton) {
        goals[0] = 0
        goals[1] = 0
        badCounter = 0
        goodCounter = 0
        evaluateDay()
        updateChart(data: players, vals: goals.map{ Double($0) })
    }
    func fetchEvents() {
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day =  60
        let futureDate = calendar.date(byAdding: dateComponents, to: now)
        let eventsPredicate = self.eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil)
        let events = self.eventStore.events(matching: eventsPredicate)
        print(now)
        
        for event in events{
            if(event.endDate.timeIntervalSinceNow == 0.0) {
                print("--------------------------EVENT JUST ENDED!!!")
            
            }
            let hour = Calendar.current.component(.hour, from: event.endDate)
            let minute = Calendar.current.component(.minute, from: event.endDate)
            print("\(hour) : \(minute)")
            
           
            print("event: \(String(describing: event.title)) + \(event.endDate as Date)")
        }
        
    }
    
    func evaluateDay() {
        let totalCount = badCounter + goodCounter
        print("Good Counter: \(goodCounter)")
        print("Bad Counter: \(badCounter)")
        if (badCounter > 0 && goodCounter > 0) {
            let dayScore = String(round(((goodCounter / totalCount) * 100.0)*100)/100)
            print("DayScore: " + dayScore)
            MainLabel.text = "Your day has been " + dayScore + "% good!"
        }
        
        
    }
    
    @IBAction func UndoPress(_ sender: UIButton) {
        if(lastClick.elementsEqual("good") == true) {
            
            goals[0] -= 1
            goodCounter -= 1
            evaluateDay()
            updateChart(data: players, vals: goals.map{ Double($0) })
        } else if(lastClick.elementsEqual("bad") == true) {
            
            goals[1] -= 1
            badCounter -= 1
            evaluateDay()
            updateChart(data: players, vals: goals.map{ Double($0) })
        }
        UndoButton.isHidden = true
    }
    @IBAction func BadButtonClick(_ sender: UIButton) {
        badCounter+=1
        lastClick = "bad"
//        print(badCounter)
        goals[1] += 1
        
        updateChart(data: players, vals: goals.map{ Double($0) })
        UndoButton.isHidden = false
    }
    
    @IBAction func GoodButtonClick(_ sender: UIButton) {
        goodCounter+=1
        lastClick = "good"
//        print(goodCounter)
        goals[0] += 1
        updateChart(data: players, vals: goals.map{ Double($0) })
        UndoButton.isHidden = false
     
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        InstructionView.isHidden = true
        evaluateDay()
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        pieChart.data = pieChartData
    }
    
    func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        let colors: [UIColor] = [UIColor.systemBlue, UIColor.systemGray]
        return colors
    }
    
    func updateChart(data: [String], vals: [Double]) {
        customizeChart(dataPoints: data, values: vals)
    }
    
    
}

