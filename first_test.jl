using FuzzyLogic
using Distributions
using Random

# Define fuzzy sets for the mean
mean_low = TriangularFS(-Inf, 2.0, 4.0, "mean_low")
mean_medium = TriangularFS(3.0, 3.5, 4.0, "mean_medium")
mean_high = TriangularFS(3.0, 4.0, Inf, "mean_high")

# Define fuzzy sets for the standard deviation
std_low = TriangularFS(-Inf, 0.5, 1.0, "std_low")
std_medium = TriangularFS(0.8, 1.0, 1.2, "std_medium")
std_high = TriangularFS(1.0, Inf, Inf, "std_high")

# Define fuzzy sets for probability adjustments
prob_adjust_low = TriangularFS(-Inf, -0.1, 0.0, "prob_adjust_low")
prob_adjust_medium = TriangularFS(-0.1, 0.0, 0.1, "prob_adjust_medium")
prob_adjust_high = TriangularFS(0.0, 0.1, Inf, "prob_adjust_high")

# Create a fuzzy inference system
fis = FuzzyInferenceSystem()

# Add fuzzy sets to the fuzzy inference system
addInputFuzzySet(fis, "mean", mean_low)
addInputFuzzySet(fis, "mean", mean_medium)
addInputFuzzySet(fis, "mean", mean_high)

addInputFuzzySet(fis, "std", std_low)
addInputFuzzySet(fis, "std", std_medium)
addInputFuzzySet(fis, "std", std_high)

addOutputFuzzySet(fis, "prob_adjust", prob_adjust_low)
addOutputFuzzySet(fis, "prob_adjust", prob_adjust_medium)
addOutputFuzzySet(fis, "prob_adjust", prob_adjust_high)

# Define fuzzy rules
addFuzzyRule(fis, ["mean", "mean_low", "std", "std_low"], "prob_adjust", "prob_adjust_high")
addFuzzyRule(fis, ["mean", "mean_medium", "std", "std_medium"], "prob_adjust", "prob_adjust_medium")
addFuzzyRule(fis, ["mean", "mean_high", "std", "std_high"], "prob_adjust", "prob_adjust_low")

# Function to generate synthetic data
function generate_synthetic_data(probabilities, num_respondents, num_items)
    responses = [rand(Categorical(probabilities), num_items) for _ in 1:num_respondents]
    construct_averages = [mean(response) for response in responses]
    return mean(construct_averages), std(construct_averages)
end

# Desired mean and standard deviation
desired_mean = 3.5
desired_std = 1.0

# Initial probabilities for the multinomial distribution
initial_probabilities = [0.1, 0.2, 0.4, 0.2, 0.1]

# Iterative process to adjust probabilities
for iteration in 1:100
    # Generate synthetic data using current probabilities
    current_mean, current_std = generate_synthetic_data(initial_probabilities, 100, 5)

    # Use the fuzzy inference system to get adjustment suggestions
    adjustment = evalFIS(fis, Dict("mean" => current_mean, "std" => current_std))["prob_adjust"]

    # Adjust probabilities based on the fuzzy inference system output
    initial_probabilities .+= adjustment

    # Ensure probabilities remain within valid bounds
    initial_probabilities = max.(0, min.(1, initial_probabilities))
    initial_probabilities = initial_probabilities ./ sum(initial_probabilities)

    # Check if the desired mean and standard deviation are achieved
    if isapprox(current_mean, desired_mean, atol=0.01) && isapprox(current_std, desired_std, atol=0.01)
        println("Desired mean and standard deviation achieved.")
        break
    end
end

println("Adjusted Probabilities: ", initial_probabilities)
