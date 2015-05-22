require 'matrix' # perform the matrix operation

class PredictionRegression
	@@TYPE=["linear","polynomial", "exponential", "logarithmic"]
	# read the arguments from the command line and jump to the specified regression
	def initialize x, y
		@x=x
		@y=y
		@expectY=Array.new
		@coefficient=Array.new
		@variance=2**1000
	end

	# perform linear regression
	def linearRegression()
		sumXY=0.0
		sumXSquare=0.0
		i=0
		xAverage=calculateAverage(@x)
		yAverage=calculateAverage(@y)
		begin 
			sumXY+=@x[i]*@y[i]
			sumXSquare+=@x[i]**2
			i+=1
		end while i<@x.length
		b=(sumXY-@x.length*xAverage*yAverage)/(sumXSquare-@x.length*xAverage**2)
		a=yAverage-b*xAverage
		a=a.round(2) # return 2 decimal places
		b=b.round(2) # return 2 decimal places
		@coefficient << a
		@coefficient << b
		calculateExpectY(@coefficient,"linear")
	end

	# perform polynomial regression
	def polynomialRegression(degree)
		x_data = @x.map { |x_i| (0..degree).map { |pow| (x_i**pow).to_f } }
		mx = Matrix[*x_data]
		my = Matrix.column_vector(@y)
		coefficients = ((mx.t * mx).inv * mx.t * my).transpose.to_a[0] # obtain all the coefficients from low degree to high degree
		coefficients.each_with_index do |item,index|
			coefficients[index]=item.round(2) # return 2 decimal places
		end
		calculateExpectY(coefficients,"polynomial")
	end

	# perform exponential regression
	def exponentialRegression()
		sumlny=0.0
		sumXSquare=0.0
		sumX=0.0
		sumXlny=0.0
		i=0
		begin 
			sumlny+=Math.log(@y[i])
			sumXSquare+=@x[i]**2
			sumX+=@x[i]
			sumXlny+=@x[i]*Math.log(@y[i])
			i+=1
			# catch Math::DomainError
			rescue Math::DomainError
			puts "Cannot perform exponential regression on this data ! "
			exit(1)
		end while i<@x.length
		a=(sumlny*sumXSquare-sumX*sumXlny)/(@x.length*sumXSquare-sumX**2)
		b=(@x.length*sumXlny-sumX*sumlny)/(@x.length*sumXSquare-sumX**2)
		a=Math::E**a
		a=a.round(2) # return 2 decimal places
		b=b.round(2) # return 2 decimal places
		@coefficient << a
		@coefficient << b
		calculateExpectY(@coefficient,"exponential") 
	end

	# perform logarithmic regression
	def logarithmicRegression()
		sumYlnx=0.0
		sumY=0.0
		sumlnx=0.0
		sumlnxSquare=0.0
		i=0
		begin 
			sumYlnx+=@y[i]*Math.log(@x[i])
			sumY+=@y[i]
			sumlnx+=Math.log(@x[i])
			sumlnxSquare+=Math.log(@x[i])**2
			i+=1
			# catch Math::DomainError
			rescue Math::DomainError
			puts "Cannot perform exponential regression on this data ! "
			exit(1)
		end while i<@x.length
		b=(@x.length*sumYlnx-sumY*sumlnx)/(@x.length*sumlnxSquare-sumlnx**2)
		a=(sumY-b*sumlnx)/@x.length
		b=b.round(2) # return 2 decimal places
		a=a.round(2) # return 2 decimal places
		@coefficient << a
		@coefficient << b
		calculateExpectY(@coefficient,"logarithmic") 
	end

	# calculate the average variance
	# - return: average variance
	def calculateAverageVariance()
		i=0
		sumY_expectY=0.0
		begin 
			sumY_expectY+=(@y[i]-@expectY[i])**2
			i+=1
		end while i<@x.length
		variance=sumY_expectY/@x.length
		return variance
	end

	# calculate the expect value through the regression equation
	# - coefficient: coefficient array obtained by regression
	# - type: regression type
	def calculateExpectY(coefficient,type)
		sum=0.0
		case type
		when @@TYPE[0]
			@x.each do |x|
				@expectY << coefficient[1]*x+coefficient[0]
			end
			@variance=calculateAverageVariance
		when @@TYPE[1]
			@x.each_with_index do |x,i|
				coefficient.each_with_index do |item,index|
					sum+=item*@x[i]**index
				end
				@expectY << sum.round(2)
				sum=0.0
			end
			tmp=calculateAverageVariance
			# record the coefficient with minimum variance
			if tmp<@variance
				@variance=tmp
				@coefficient=coefficient			
			end		
			@expectY=Array.new
		when @@TYPE[2]
			@x.each do |x|
				@expectY << coefficient[0]*Math::E**(coefficient[1]*x)
			end
			@variance=calculateAverageVariance
		when @@TYPE[3]
			@x.each do |x|
				@expectY << coefficient[1]*Math.log(x)+coefficient[0]
			end
			@variance=calculateAverageVariance
		end		
	end

	# calculate the average for an integer array
	# - array: float array
	# - return: the average of float array
	def calculateAverage(array)
		sum=0.0
		array.each do |item|
			sum=sum+item.to_f
		end
		return sum/array.length
	end
end