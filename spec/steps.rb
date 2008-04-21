steps_for :spec do
  
  Given "trivial failing step" do
    false.should be_true
  end

  Given "trivial passing step" do
    true.should be_true
  end
  
  Given "nontrivial passing step" do
    SpecificModel.create
  end
  
  Given "$one argument" do |arg|
    $arg = arg
  end
  
  Given "$one $two arguments" do |arg1, arg2|
    $arg = [arg1, arg2]
  end

end