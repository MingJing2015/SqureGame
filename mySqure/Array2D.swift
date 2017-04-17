//
//  Array2D.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//

// Class , not struct !
// game logic will require a single copy of this data structure to persist across the entire game.

// typed parameter: <T>. This allows our array to store any data type and remain a general-purpose tool.

class Array2D<T> {
    
    let columns: Int
    
    let rows: Int
    
    // declare an actual Swift array; it will be the underlying data structure which maintains references to our objects. 
    // It's declared with type <T?>.
    // An optional value is just that, optional. Optional variables may or may not contain data, and they may in fact be nil, or empty. nil locations found on our game board will represent empty spots where no block is present.

    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        
        self.columns = columns
        
        self.rows = rows
        
        // store all the objects our game board requires, 200 in our case.
        // array = Array<T?>(count:rows * columns, repeatedValue: nil)
        array = Array<T?>(repeating: nil, count:rows * columns)
    }
    
    // #4  Classes, structures, and enumerations can define subscripts, which are shortcuts for accessing the member elements of a collection, list, or sequence: someArray[index]  someDictionary[key].
    // have a subscript capable of supporting array[column, row]
    
    subscript(column: Int, row: Int) -> T? {
        
        get {
            return array[(row * columns) + column]
        }
        
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}
