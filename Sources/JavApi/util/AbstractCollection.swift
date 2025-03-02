/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

extension java.util {
  
  /**
   * Class {@code AbstractCollection} is an abstract implementation of the {@code
   * Collection} interface. A subclass must implement the abstract methods {@code
   * iterator()} and {@code size()} to create an immutable collection. To create a
   * modifiable collection it's necessary to override the {@code add()} method that
   * currently throws an {@code UnsupportedOperationException}.
   *
   * @since 1.2
   */
  open class AbstractCollection<E> : Collection where E: Equatable {
    
    public typealias IteratorType = AbstractCollection<E>
    
    public typealias Element = E
    
    /**
     * Constructs a new instance of this AbstractCollection.
     */
    public init() {
    }
    
    open func add(_ element: E?) throws -> Bool {
      throw java.lang.Throwable.UnsupportedOperationException()
    }
    
    /**
     * Attempts to add all of the objects contained in {@code collection}
     * to the contents of this {@code Collection} (optional). This implementation
     * iterates over the given {@code Collection} and calls {@code add} for each
     * element. If any of these calls return {@code true}, then {@code true} is
     * returned as result of this method call, {@code false} otherwise. If this
     * {@code Collection} does not support adding elements, an {@code
     * UnsupportedOperationException} is thrown.
     * <p>
     * If the passed {@code Collection} is changed during the process of adding elements
     * to this {@code Collection}, the behavior depends on the behavior of the passed
     * {@code Collection}.
     *
     * @param collection
     *            the collection of objects.
     * @return {@code true} if this {@code Collection} is modified, {@code false}
     *         otherwise.
     * @throws UnsupportedOperationException
     *                if adding to this {@code Collection} is not supported.
     * @throws ClassCastException
     *                if the class of an object is inappropriate for this
     *                {@code Collection}.
     * @throws IllegalArgumentException
     *                if an object cannot be added to this {@code Collection}.
     * @throws NullPointerException
     *                if {@code collection} is {@code null}, or if it contains
     *                {@code null} elements and this {@code Collection} does not support
     *                such elements.
     */
    open func addAll(_ collection: any java.util.Collection<E?>) throws -> Bool {
      var result = false;
      let it = collection.iterator();
      while (it.hasNext()) {
        let next = try it.next()!
        if try add(next) {
          result = true
        }
      }
      return result
    }
    
    /**
     * Removes all elements from this {@code Collection}, leaving it empty (optional).
     * This implementation iterates over this {@code Collection} and calls the {@code
     * remove} method on each element. If the iterator does not support removal
     * of elements, an {@code UnsupportedOperationException} is thrown.
     * <p>
     * Concrete implementations usually can clear a {@code Collection} more efficiently
     * and should therefore overwrite this method.
     *
     * @throws UnsupportedOperationException
     *                it the iterator does not support removing elements from
     *                this {@code Collection}
     * @see #iterator
     * @see #isEmpty
     * @see #size
     */
    public func clear() {
      let it = iterator();
      while (it.hasNext()) {
        _ = try! it.next();
        it.remove();
      }
    }
    
    /**
     * Tests whether this {@code Collection} contains the specified object. This
     * implementation iterates over this {@code Collection} and tests, whether any
     * element is equal to the given object. If {@code object != null} then
     * {@code object.equals(e)} is called for each element {@code e} returned by
     * the iterator until the element is found. If {@code object == null} then
     * each element {@code e} returned by the iterator is compared with the test
     * {@code e == null}.
     *
     * @param object
     *            the object to search for.
     * @return {@code true} if object is an element of this {@code Collection}, {@code
     *         false} otherwise.
     * @throws ClassCastException
     *                if the object to look for isn't of the correct type.
     * @throws NullPointerException
     *                if the object to look for is {@code null} and this
     *                {@code Collection} doesn't support {@code null} elements.
     */
    open func contains(_ element: E?) -> Bool {
      let it = iterator()
      if (element != nil) {
        while (it.hasNext()) {
          if (element == (try! it.next())) {
            return true;
          }
        }
      } else {
        while (it.hasNext()) {
          if (try! it.next() == nil) {
            return true;
          }
        }
      }
      return false;
    }
    
    /**
     * Tests whether this {@code Collection} contains all objects contained in the
     * specified {@code Collection}. This implementation iterates over the specified
     * {@code Collection}. If one element returned by the iterator is not contained in
     * this {@code Collection}, then {@code false} is returned; {@code true} otherwise.
     *
     * @param collection
     *            the collection of objects.
     * @return {@code true} if all objects in the specified {@code Collection} are
     *         elements of this {@code Collection}, {@code false} otherwise.
     * @throws ClassCastException
     *                if one or more elements of {@code collection} isn't of the
     *                correct type.
     * @throws NullPointerException
     *                if {@code collection} contains at least one {@code null}
     *                element and this {@code Collection} doesn't support {@code null}
     *                elements.
     * @throws NullPointerException
     *                if {@code collection} is {@code null}.
     */
    open func containsAll(_ collection: any java.util.Collection<E?>) -> Bool {
      let it = collection.iterator();
      while (it.hasNext()) {
        let next = try! it.next()
        if !self.contains(next!) {
          return false;
        }
      }
      return true;
    }
    
    /**
     * Returns if this {@code Collection} contains no elements. This implementation
     * tests, whether {@code size} returns 0.
     *
     * @return {@code true} if this {@code Collection} has no elements, {@code false}
     *         otherwise.
     *
     * @see #size
     */
    open func isEmpty() -> Bool{
      return size() == 0;
    }
    
    /**
     * Returns an instance of {@link Iterator} that may be used to access the
     * objects contained by this {@code Collection}. The order in which the elements are
     * returned by the {@link Iterator} is not defined unless the instance of the
     * {@code Collection} has a defined order.  In that case, the elements are returned in that order.
     * <p>
     * In this class this method is declared abstract and has to be implemented
     * by concrete {@code Collection} implementations.
     *
     * @return an iterator for accessing the {@code Collection} contents.
     */
    open func iterator() -> any java.util.Iterator<E> {
      fatalError("implementation in subclass needed")
    }
    
    /**
     * Removes one instance of the specified object from this {@code Collection} if one
     * is contained (optional). This implementation iterates over this
     * {@code Collection} and tests for each element {@code e} returned by the iterator,
     * whether {@code e} is equal to the given object. If {@code object != null}
     * then this test is performed using {@code object.equals(e)}, otherwise
     * using {@code object == null}. If an element equal to the given object is
     * found, then the {@code remove} method is called on the iterator and
     * {@code true} is returned, {@code false} otherwise. If the iterator does
     * not support removing elements, an {@code UnsupportedOperationException}
     * is thrown.
     *
     * @param object
     *            the object to remove.
     * @return {@code true} if this {@code Collection} is modified, {@code false}
     *         otherwise.
     * @throws UnsupportedOperationException
     *                if removing from this {@code Collection} is not supported.
     * @throws ClassCastException
     *                if the object passed is not of the correct type.
     * @throws NullPointerException
     *                if {@code object} is {@code null} and this {@code Collection}
     *                doesn't support {@code null} elements.
     */
    open func remove(_ element: E?) -> Bool {
      let it = iterator();
      if (element != nil) {
        while (it.hasNext()) {
          if (element == (try! it.next())) {
            it.remove();
            return true
          }
        }
      } else {
        while (it.hasNext()) {
          if (try! it.next() == nil) {
            it.remove();
            return true;
          }
        }
      }
      return false;
    }
    
    /**
     * Removes all occurrences in this {@code Collection} of each object in the
     * specified {@code Collection} (optional). After this method returns none of the
     * elements in the passed {@code Collection} can be found in this {@code Collection}
     * anymore.
     * <p>
     * This implementation iterates over this {@code Collection} and tests for each
     * element {@code e} returned by the iterator, whether it is contained in
     * the specified {@code Collection}. If this test is positive, then the {@code
     * remove} method is called on the iterator. If the iterator does not
     * support removing elements, an {@code UnsupportedOperationException} is
     * thrown.
     *
     * @param collection
     *            the collection of objects to remove.
     * @return {@code true} if this {@code Collection} is modified, {@code false}
     *         otherwise.
     * @throws UnsupportedOperationException
     *                if removing from this {@code Collection} is not supported.
     * @throws ClassCastException
     *                if one or more elements of {@code collection} isn't of the
     *                correct type.
     * @throws NullPointerException
     *                if {@code collection} contains at least one {@code null}
     *                element and this {@code Collection} doesn't support {@code null}
     *                elements.
     * @throws NullPointerException
     *                if {@code collection} is {@code null}.
     */
    open func removeAll(_ collection: any java.util.Collection<E?>) -> Bool {
      var result = false;
      let it = iterator();
      while (it.hasNext()) {
        if (collection.contains(try! it.next())) {
          it.remove();
          result = true;
        }
      }
      return result;
    }
    
    /**
     * Removes all objects from this {@code Collection} that are not also found in the
     * {@code Collection} passed (optional). After this method returns this {@code Collection}
     * will only contain elements that also can be found in the {@code Collection}
     * passed to this method.
     * <p>
     * This implementation iterates over this {@code Collection} and tests for each
     * element {@code e} returned by the iterator, whether it is contained in
     * the specified {@code Collection}. If this test is negative, then the {@code
     * remove} method is called on the iterator. If the iterator does not
     * support removing elements, an {@code UnsupportedOperationException} is
     * thrown.
     *
     * @param collection
     *            the collection of objects to retain.
     * @return {@code true} if this {@code Collection} is modified, {@code false}
     *         otherwise.
     * @throws UnsupportedOperationException
     *                if removing from this {@code Collection} is not supported.
     * @throws ClassCastException
     *                if one or more elements of {@code collection}
     *                isn't of the correct type.
     * @throws NullPointerException
     *                if {@code collection} contains at least one
     *                {@code null} element and this {@code Collection} doesn't support
     *                {@code null} elements.
     * @throws NullPointerException
     *                if {@code collection} is {@code null}.
     */
    open func retainAll(_ collection: any java.util.Collection<E?>) -> Bool {
      var result = false;
      let it = iterator();
      while (it.hasNext()) {
        let next : E? = try! it.next()
        _ = collection.contains(next)
        if !collection.contains(next) {
          it.remove()
          result = true
        }
      }
      return result
    }
    
    /**
     * Returns a count of how many objects this {@code Collection} contains.
     * <p>
     * In this class this method is declared abstract and has to be implemented
     * by concrete {@code Collection} implementations.
     *
     * @return how many objects this {@code Collection} contains, or {@code Integer.MAX_VALUE}
     *         if there are more than {@code Integer.MAX_VALUE} elements in this
     *         {@code Collection}.
     */
    open func size () -> Int {
      fatalError("need to implement in concrete subtype")
    }
    
    open func toArray () -> [E?] {
      var array : [E?] = []
      let iterator = self.iterator()
      while iterator.hasNext() {
        let next : E? = try! iterator.next()
        array.append(next)
      }
      return array;
    }
    
    public func toArray(_ array: inout [E?]) -> [E?] {
      let asArray = self.toArray()
      for i in 0..<array.count {
        if asArray.count < i {
          array[i] = asArray[i]
        }
        else {
          array[i] = nil
        }
      }
      for i in array.count..<asArray.count {
        array.append(asArray[i])
      }
      return array
    }
    
    /**
     * Returns the string representation of this {@code Collection}. The presentation
     * has a specific format. It is enclosed by square brackets ("[]"). Elements
     * are separated by ', ' (comma and space).
     *
     * @return the string representation of this {@code Collection}.
     */
    open func toString() -> String {
      if (isEmpty()) {
        return "[]"; //$NON-NLS-1$
      }
      
      let buffer = StringBuilder()//size() * 16)
      _ = buffer.append("[")
      let it = iterator();
      while (it.hasNext()) {
        let next = try! it.next()
        if (next != self as? E) {
          _ = buffer.append("\(String(describing: next))")
        } else {
          _ = buffer.append("(this Collection)"); //$NON-NLS-1$
        }
        if (it.hasNext()) {
          _ = buffer.append(", "); //$NON-NLS-1$
        }
      }
      _ = buffer.append("]");
      return buffer.toString();
    }


    public func next() -> E? {
      fatalError("need to implement in concrete subtype")
    }
    
  }
}
