#import "Basic";
Compiler :: #import "Compiler";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
#import "Sort";
#import "System";

#load "main.jai";

#run {
  Compiler.set_build_options_dc(.{do_output=false});

  print("******************************************************\n");
  print("******************************************************\n");

  my_array : [..] int;
  

  for 1..10 array_add(*my_array, it);

  view := array_view(my_array, 0);

  for view {
    print("=======================\n");
    print("before removal:\n");
    print_vars(it, it_index, my_array, view);
    array_ordered_remove_by_index(*my_array, it_index);
    print("after removal:\n");
    print_vars(it, it_index, my_array, view);
    print("=======================\n\n\n");
  }
}