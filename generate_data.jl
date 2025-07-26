using Distributions
using Random

# Desired mean and standard deviation
desired_mean = 3.5
desired_std = 1.0

# Initial probabilities for the multinomial distribution
init_prob = [0.1, 0.2, 0.4, 0.2, 0.1]

# Function to generate synthetic data
function generate_synthetic_data(probabilities, num_respondents, num_items)
    responses = [rand(Categorical(probabilities), num_items) for _ in 1:num_respondents]
    construct_averages = [mean(response) for response in responses]
    return mean(construct_averages), std(construct_averages)
end


generate_synthetic_data(init_prob, 100, 5)

