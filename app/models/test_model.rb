# A model used in testing that the testing systems are working as expected.
class TestModel
	@@generated_instances = []
	
	attr_accessor :test_attribute
	
	def self.columns
		[TestColumnDef.new('test_attribute')]
	end
	
	def self.length
		@@generated_instances.length
	end
	
	def self.include?(value)
		@@generated_instances.include?(value)
	end
	
	def self.destroy_all
		@@generated_instances = []
	end
	
	def save!
		@@generated_instances << self
	end
	
	def ==(arg)
		self.test_attribute == arg.is_a?(TestModel) ? arg.test_attribute : arg
	end
	
	def testable_method
		self.test_attribute = 'Method tested.'
		test_attribute
	end
	
	def testable_feature
		self.test_attribute = 'Feature tested.'
		test_attribute
	end
end

# A model to simulate data table columns for TestModel objects.
class TestColumnDef
	attr_accessor :name
	
	def initialize(label)
		self.name = label
	end
end
