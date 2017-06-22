# Include these examples in the specs of classes which are expected to conform to the Login interface.
# > it_behaves_like 'Login Interface', instance_of_class
shared_examples_for 'Login Interface' do |login_interface_object|
  it 'should respond to user_class' do
    expect(login_interface_object).to respond_to(:user_class)
  end
  it 'should respond to user_class=' do
    expect(login_interface_object).to respond_to(:user_class=)
  end
  it 'should respond to user' do
    expect(login_interface_object).to respond_to(:user)
  end
end
