function y = quick_sort(x, left, right)
    if( left >= right)
       %nothing already sorted
       y = x;
    else
       [t1,pivot_loc] = partition(x, left, right);
       t1 = quick_sort(t1, left, pivot_loc-1);
       t1 = quick_sort(t1, pivot_loc+1, right);
       y = t1;
    end
end