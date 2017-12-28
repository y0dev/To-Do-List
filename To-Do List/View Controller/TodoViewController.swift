//
//  ViewController.swift
//  To-Do List
//
//  Created by Devontae Reid on 12/21/17.
//  Copyright © 2017 Devontae Reid. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController, NewTodoViewControllerProtocol {

    let cellIdForTableView = "todoCell"
    var todos = [Todo]()
    var selectedTodos = [Todo]()
    var todosDict = [String:String]()
    var numOfTaskDone = 0
    
    var tableView: UITableView!
    
    let backgroundColor = UIColor(rgb: 0xA47AF4)
    let insideTextColor = UIColor(rgb: 0xDCDBE8)
    let outsideTextColor = UIColor(rgb: 0xA492D0)
    let selectedTextColor = UIColor(rgb: 0xA492D0)
    
    
    var calendarView: JTAppleCalendarView!
    let cellIdForCalendar = "id"
    let formatter = DateFormatter()
    
    let addNewTask: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        let image = UIImage(named: "plus")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    let monthLabel:  UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: lbl.font.fontName, size: 34)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    let yearLabel:  UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: lbl.font.fontName, size: 20)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    var dayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = "To-Do List"
        // This is to remove view underneath navigation bar
//        self.navigationController?.navigationBar.isTranslucent = false
        
        if let savedTodos = Todo.loadTodos() {
            todos = savedTodos
            todos.sort{ $0.dueDate < $1.dueDate }
        } else {
            todos = Todo.loadSampleTodos()
            todos.sort{ $0.dueDate < $1.dueDate }
        }
        updateTaskCount()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup
    private func setupTableView() {
        
        self.addNewTask.addTarget(self, action: #selector(addNewTodo(_:)), for: .touchUpInside)
        
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
        self.tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: cellIdForTableView)
        self.view.addSubview(tableView)
        
        self.view.backgroundColor = backgroundColor
        
        
        // Setup up calendarView
        self.calendarView = JTAppleCalendarView()
        self.view.addSubview(calendarView)
        self.calendarView.scrollDirection = .horizontal
        self.calendarView.showsHorizontalScrollIndicator = false
        self.calendarView.isScrollEnabled = true
        self.calendarView.isPagingEnabled = true
        self.calendarView.minimumLineSpacing = 0
        self.calendarView.minimumInteritemSpacing = 0
        self.calendarView.calendarDelegate = self
        self.calendarView.calendarDataSource = self
        self.calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.calendarView.backgroundColor = .clear
        self.calendarView.register(CustomCalendarCell.self, forCellWithReuseIdentifier: cellIdForCalendar)
        self.calendarView.scrollToDate(Date(),animateScroll: false)
        self.calendarView.selectDates([ Date() ])
        self.calendarView.reloadData()
        self.view.addSubview(monthLabel)
        self.view.addSubview(yearLabel)
        self.view.addSubview(addNewTask)
        
        // This is used to labels to present the months and year
        self.calendarView.visibleDates() { (visibleDates) in
            let date = visibleDates.monthDates.first!.date
            
            self.formatter.dateFormat = "MMMM"
            self.monthLabel.text = self.formatter.string(from: date)
            
            self.formatter.dateFormat = "yyyy"
            self.yearLabel.text = self.formatter.string(from: date)
        }
        
        setupDaysView()
        formatTodosDict()
        
        self.view.addContraintsWithFormat(format: "H:|[v0]|", views: calendarView)
        self.view.addContraintsWithFormat(format: "V:|-40-[v0]-15-[v1]-10-[v2][v3(240)][v4]|", views: yearLabel,monthLabel,dayView,calendarView,tableView)
        self.view.addContraintsWithFormat(format: "H:|[v0]|", views: dayView)
        self.view.addContraintsWithFormat(format: "H:|-20-[v0]", views: monthLabel)
        self.view.addContraintsWithFormat(format: "H:|-20-[v0]", views: yearLabel)
        
        self.view.addContraintsWithFormat(format: "H:|[v0]|", views: tableView)
        self.view.addContraintsWithFormat(format: "H:[v0(30)]-20-|", views: addNewTask)
        self.view.addContraintsWithFormat(format: "V:|-40-[v0(30)]", views: addNewTask)
        
        
    }
    
    
    
    private func setupDaysView() {
        self.view.addSubview(dayView)
        
        let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        var daysLabels = [UILabel]()
        
        for day in days {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = day
            lbl.textAlignment = .center
            lbl.textColor = insideTextColor
            daysLabels.append(lbl)
        }
        
        for lbl in daysLabels {
            self.dayView.addSubview(lbl)
            self.dayView.addContraintsWithFormat(format: "V:|[v0]|", views: lbl)
        }
        
        self.dayView.backgroundColor = .clear
        self.dayView.addContraintsWithFormat(format: "H:|[v0(60)][v1(60)][v2(60)][v3(60)][v4(60)][v5(60)][v6]|", views: daysLabels[0],daysLabels[1],daysLabels[2],daysLabels[3],daysLabels[4],daysLabels[5],daysLabels[6])
        
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let customCell = cell as? CustomCalendarCell else { return }
        
        handleCellSelectedColor(cell: customCell, cellState: cellState)
        handleTextColor(cell: customCell, cellState: cellState)
        handleCellEvents(cell: customCell, cellState: cellState)
    }
    
    func handleTextColor(cell:CustomCalendarCell,cellState: CellState) {
        
        let todayDate = Date()
        formatter.dateFormat = "MM dd yyyy"
        let todatDateString = formatter.string(from: todayDate)
        let monthDateString = formatter.string(from: cellState.date)
        
        if todatDateString == monthDateString {
            cell.dateLabel.textColor = .red
        } else {
            handleCalendarCellColor(cell: cell, cellState: cellState)
        }

    }
    
    func handleCalendarCellColor(cell: CustomCalendarCell, cellState: CellState) {
        cell.dateLabel.textColor = cellState.dateBelongsTo == .thisMonth ? insideTextColor : outsideTextColor
    }
    
    func handleCellSelectedColor(cell: CustomCalendarCell, cellState: CellState) {
        cell.selectedView.isHidden = cellState.isSelected ? false : true
    }
    
    func handleCellEvents(cell: CustomCalendarCell, cellState: CellState) {
        cell.eventDotView.isHidden = !todosDict.contains { $0.key == formatter.string(from: cellState.date) }
    }
    
    
    // MARK: Table View Button Actions
    
    @objc func addNewTodo(_: UIBarButtonItem){
        let dvc = NewTodoViewController()
        dvc.delegate = self
        self.present(dvc, animated: true, completion: nil)
    }
    
    // MARK: Protocol Functions
    func completeButtonTapped(sender: TodoTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let todo = todos[indexPath.row]
            todo.isComplete = !todo.isComplete
            todos[indexPath.row] = todo
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
        updateTaskCount()
        Todo.saveTodos(todos)
        tableView.reloadData()
    }
    
    func deleteButtonTapped(sender: TodoTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateTaskCount()
            tableView.reloadData()
            Todo.saveTodos(todos)
        }
    }
    
    func editButtonTapped(sender: TodoTableViewCell) {
        let dvc = EditTodoViewController()
        dvc.delegate = self
        dvc.todo = Todo(title: sender.titleLabel.text!, dueDate: sender.date!, notes: sender.notesLabel.text)
        print(dvc.todo!.dueDate)
        self.present(dvc, animated: true, completion: nil)
    }
    
    func addTodo(todo: Todo) {
        self.todos.append(todo)
        Todo.saveTodos(todos)
        tableView.reloadData()
    }
    
    func updateTaskCount() {
        numOfTaskDone = 0
        for i in 0..<todos.count {
            if todos[i].isComplete {
                numOfTaskDone = numOfTaskDone + 1
            }
        }
    }
    
    func formatTodosDict() {
        DispatchQueue.global().asyncAfter(deadline: .now()) {
            let todoObjects = self.createTodosDict()
            for (date, event) in todoObjects {
                let stringDate = self.formatter.string(from: date)
                self.todosDict[stringDate] = event
            }
        }
        
        DispatchQueue.main.async {
            self.calendarView.reloadData()
        }
    }
    
    func createTodosDict() -> [Date:String] {
        formatter.dateFormat = "MM dd yyyy"
        
        var dict = [Date:String]()
        
        for todo in todos {
            dict[todo.dueDate] =  todo.title
        }
        return dict
    }
    
}


//MARK: Tableview delegate and datasource

extension TodoViewController:  UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTodos.count != 0 ? selectedTodos.count : todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdForTableView, for: indexPath) as! TodoTableViewCell
        
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        
        // Create a todo object for each object in array
        let todo = selectedTodos.count != 0 ? selectedTodos[indexPath.row] : todos[indexPath.row]
        
        // Set labels
        cell.titleLabel.text = todo.title
        cell.notesLabel.text = todo.notes!
        cell.date = todo.dueDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "h:mm a"
        
        cell.dueDateLabel.text = "Due: \(dateFormatter.string(from: todo.dueDate))"
        
        cell.checkView.isHidden = !todo.isComplete ? true : false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
        let completedAction = UIContextualAction(style: .normal, title: cell.checkView.isHidden ? "Check" : "Uncheck") { (action, view, _) in
            self.completeButtonTapped(sender: cell)
        }
        completedAction.backgroundColor = UIColor(rgb: 0x7ABA7A)
        return UISwipeActionsConfiguration(actions: [completedAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, _) in
            self.deleteButtonTapped(sender: cell)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
        self.editButtonTapped(sender: cell)
    }
}


// MARK: Calendar Delegate and Datasource

extension TodoViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: cellIdForCalendar, for: indexPath) as! CustomCalendarCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "MM dd yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "04 17 1993")
        let endDate = formatter.date(from: "01 01 2019")
        
        return ConfigurationParameters(startDate: startDate!, endDate: endDate!)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = formatter.string(from: date)
        
        self.formatter.dateFormat = "yyyy"
        self.yearLabel.text = self.formatter.string(from: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        formatter.dateFormat = "MM dd yyyy"
        let cellDateString = formatter.string(from: cellState.date)
        selectedTodos = [Todo]()
        for todo in todos {
            let todoDateString = formatter.string(from: todo.dueDate)
            if todoDateString == cellDateString {
                selectedTodos.append(todo)
            }
        }
        configureCell(cell: cell, cellState: cellState)
        cell?.bounce()
        tableView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    
}


