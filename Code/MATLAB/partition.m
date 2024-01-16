function [y,pivot_loc] = partition(x, left, right)
 pivot = x(right);
 left_ptr = left;
 right_ptr = right-1;
    
 while(1)
     
    while( x(left_ptr) < pivot )
     left_ptr = left_ptr+1;
    end
 
    while( (x(right_ptr) > pivot) && (right_ptr > left) ) %added >= to solve case if all elements same of array 
     right_ptr = right_ptr - 1;
    end
 
    if( left_ptr >= right_ptr )
        x(right) = x(left_ptr);
        x(left_ptr) = pivot;
        pivot_loc = left_ptr;
        y = x;
        break;
    else
        temp = x(right_ptr);
        x(right_ptr) = x(left_ptr);
        x(left_ptr) = temp;
        left_ptr = left_ptr+1;
        right_ptr = right_ptr - 1;
    end
 
 end
 
 disp(y);
 
end