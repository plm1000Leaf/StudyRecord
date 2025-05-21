//
//  Material.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/15.
//

import Foundation
import CoreData

@objc(Material)
public class Material: NSManagedObject {}

extension Material: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Material> {
        NSFetchRequest<Material>(entityName: "Material")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var label: String?
    @NSManaged public var imageData: Data?

    @NSManaged public var dailyRecord: DailyRecord?
}
