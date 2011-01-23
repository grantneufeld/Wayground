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
		if arg.is_a? TestModel
			self.test_attribute == arg.test_attribute
		else
			self.test_attribute == arg
		end
	end
	
	def testable_method
		x = 'something'
		x += '.'
		x
	end
	
	def testable_feature
		y = 'something'
		y += '.'
		y
	end
end


class TestColumnDef
	attr_accessor :name
	
	def initialize(label)
		self.name = label
	end
end
