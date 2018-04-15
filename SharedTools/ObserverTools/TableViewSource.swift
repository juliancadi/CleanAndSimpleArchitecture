//  Created by Michal Ciurus

import UIKit

final public class TableViewDataSource<V, T>: NSObject, UITableViewDataSource where V: UITableViewCell {
    
    public typealias CellConfiguration = (V, T) -> V
    
    private var observable: ValueObservable<[T]>
    private let cellIdentifier: String
    private let configureCell: CellConfiguration
    
    public let didDelete = EventObservable<IndexPath>()
    
    public init(cellIdentifier: String, observable: ValueObservable<[T]>, configureCell: @escaping CellConfiguration) {
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
        self.observable = observable
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observable.value?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? V
        
        guard let currentCell = cell else {
            fatalError("Identifier or class not registered with this table view")
        }
        
        let presenter = observable.value![indexPath.row]
        return configureCell(currentCell, presenter)
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           didDelete.fireEvent(with: indexPath)
        }
    }
    
}