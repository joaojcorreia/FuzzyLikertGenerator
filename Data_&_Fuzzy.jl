using Distributions
using Random
using FuzzyLogic
using Plots

# Desired mean and standard deviation
desired_mean = 3.5
desired_std = 1.0

# Initial probabilities for the multinomial distribution
init_prob = [0.2, 0.2, 0.2, 0.2, 0.2]

fis = @mamfis function adj(mean_dif)::mean_adjust
    mean_dif := begin
        domain = -4:4
        neg_high = LinearMF(-1, -4)
        neg_low = TriangularMF(-3, -1, 0)
        neut = TriangularMF(-1, 0, 1)
        pos_low = TriangularMF(0, 1, 3)
        pos_high = LinearMF(1, 4)
    end

    mean_adjust := begin
        domain = -0.5:0.5
        neg_strong = LinearMF(0.0, -0.5)
        neg_weak = TriangularMF(-0.25, -0.10, 0.00)
        average = TriangularMF(-0.10, 0.00, 0.10)
        pos_weak = TriangularMF(0.0, 0.10, 0.25)
        pos_strong = LinearMF(0.0, 0.5)
    end

    and = ProdAnd
    or = ProbSumOr
    implication = ProdImplication


    mean_dif == neg_high --> mean_adjust == neg_strong
    mean_dif == neg_low --> mean_adjust == neg_weak
    mean_dif == neut --> mean_adjust == average
    mean_dif == pos_low --> mean_adjust == pos_weak
    mean_dif == pos_high --> mean_adjust == pos_strong

    aggregator = ProbSumAggregator
    defuzzifier = CentroidDefuzzifier
end


# Function to generate synthetic data
function generate_synthetic_data(probabilities, num_respondents, num_items)
    responses = [rand(Categorical(probabilities), num_items) for _ in 1:num_respondents]
    construct_averages = [mean(response) for response in responses]
    return mean(construct_averages), std(construct_averages)
end


current_mean, current_std = generate_synthetic_data(init_prob, 100, 5)

fis(desired_mean - current_mean)

