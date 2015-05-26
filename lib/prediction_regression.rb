require 'matrix' # perform the matrix operation

class PredictionRegression
	@@TYPE=["linear","polynomial", "exponential", "logarithmic"]
	# read the arguments from the command line and jump to the specified regression
	def initialize x, y, period
		@x=x
		@y=y
		@periods=[]
		periodToArray(period)
		@expectY=Array.new
		@coefficientP=Array.new
		@coefficientE=Array.new
		@coefficientL=Array.new
		@varianceP=2**1000
		@varianceE=2**1000
		@varianceL=2**1000
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
		@coefficientE << a
		@coefficientE << b
		calculateExpectY(@coefficientE,"exponential") 
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
		@coefficientL << a
		@coefficientL << b		
		calculateExpectY(@coefficientL,"logarithmic") 
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
		@expectY=Array.new
		case type
		when @@TYPE[1]
			@x.each_with_index do |x,i|
				coefficient.each_with_index do |item,index|
					sum+=item*@x[i]**index
				end
				@expectY << sum.round(4)
				sum=0.0
			end
			tmp=calculateAverageVariance
			# record the coefficient with minimum variance
			if tmp<@varianceP
				@varianceP=tmp
				@coefficientP=coefficient			
			end		
		when @@TYPE[2]
			@x.each do |x|				
				@expectY << @coefficientE[0]*Math::E**(@coefficientE[1]*x)
			end
			@varianceE=calculateAverageVariance
		when @@TYPE[3]
			@x.each do |x|
				@expectY << @coefficientL[1]*Math.log(x)+@coefficientL[0]				
			end
			@varianceL=calculateAverageVariance			
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

	def periodToArray(period)
		(1..period/10).each do |i|
			@periods.push(i*10*60+Time.now.to_i)
		end
	end

	def executeRegression
		predictValue=[]
		predictPro=[]
		sum=0.0
		(2...11).each do |degree|
			polynomialRegression(degree)				
		end
		exponentialRegression		
		logarithmicRegression

		if @varianceP<@varianceL && @varianceP<@varianceE
			@periods.each_with_index do |period,i|
				@coefficientP.each_with_index do |item,index|
					sum+=item*period[i]**index
				end
				predictValue.push(sum.round(4))
				sum=0.0
			end
			predictValue.each do |pv|
				predictPro.push(pv/(pv+Math.sqrt(@varianceP)))
			end			
		elsif @varianceL<@varianceP && @varianceL<@varianceE
			@periods.each do |period|
				predictValue.push(@coefficientL[1]*Math.log(period)+@coefficientL[0])
			end
			predictValue.each do |pv|
				predictPro.push(pv/(pv+Math.sqrt(@varianceL)))
			end
		elsif @varianceE<=@varianceL && @varianceE<=@varianceP
			@periods.each do |period|
				predictValue.push(@coefficientE[0]*Math::E**(@coefficientE[1]*period))
			end
			predictValue.each do |pv|
				predictPro.push(pv/(pv+Math.sqrt(@varianceE)))
			end
		else
			(1..@periods.size).each do |i|
				predictValue.push(0)
			end
			predictValue.each do |pv|
				predictPro.push(1)
			end
		end
		return predictValue, predictPro
	end
end