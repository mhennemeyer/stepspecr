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


  
end