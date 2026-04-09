#import "Basic";
Compiler :: #import "Compiler";
#import "Hash_Table";
#import "Input";
#import "Math";
#import "Print_Vars";
#import "Random";
#import "Sort";
#import "System";

#load "utils.jai";

#run {
  Compiler.set_build_options_dc(.{do_output=false});

  nums : [..] int;
  array_add(*nums, 1);
  array_add(*nums, 2);
  array_add(*nums, 3);
  array_add(*nums, 4);


  for nums {
    array_add(*nums, nums.count + 1);
    print("%\n", nums.count);
  }
}