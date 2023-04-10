//
//  SwiftPointer.swift
//  teaksungmi
//
//  Created by LTS on 2022/04/29.
//

import Foundation


class Node<T: Equatable> {
    var value: T
    var next: Node?

    init(value: T, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

class LinkedList<T: Equatable> {
    var head: Node<T>?
    var tail: Node<T>?

    init(head: Node<T>? = nil) {
        self.head = head
        self.tail = head
    }

    func size() -> Int {
        guard var node = self.head else {
            return 0
        }
        var count = 0
        while node.next != nil {
            count += 1
            node = node.next!
        }
        return count
    }


    func findNode(at index: Int) -> Node<T>? {
        guard var node = self.head else {
            return nil
        }
        for _ in 1...index {
            guard let nextNode = node.next else {
                return nil
            }
            node = nextNode
        }
        return node
    }

    func append(_ newNode: Node<T>) {
        if let tail = self.tail {
            tail.next = newNode
            self.tail = tail.next
        } else {
            self.head = newNode
            self.tail = newNode
        }
    }

    func insert(_ newNode: Node<T>, at index: Int) {
        if self.head == nil {
            self.head = newNode
            self.tail = newNode
            return
        }
        guard let frontNode = findNode(at: index-1) else {
            self.tail?.next = newNode
            self.tail = newNode
            return
        }
        guard let nextNode = frontNode.next else {
            frontNode.next = newNode
            self.tail = newNode
            return
        }
        newNode.next = nextNode
        frontNode.next = newNode
    }

    func remove(at index: Int) {
        guard let frontNode = findNode(at: index-1) else {
            return
        }
        guard let removeNode = frontNode.next else {
            return
        }
        guard let nextNode = removeNode.next else {
            frontNode.next = nil
            self.tail = frontNode
            return
        }
        frontNode.next = nextNode
    }

    func contains(_ value: T) -> Bool {
        guard var node = self.head else {
            return false
        }
        while true {
            if node.value == value {
                return true
            }
            guard let next = node.next else {
                return false
            }
            node = next
        }
    }

    func firstIndex(of value: T) -> Int? {
        guard var node = self.head else {
            return nil
        }
        var count = 0
        while true {
            if node.value == value {
                return count
            }
            guard let next = node.next else {
                return nil
            }
            node = next
            count += 1
        }
    }
}
