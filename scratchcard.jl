using Distributions

mutable struct ScratchCard
    name::String
    price::Int64
    letters::Vector{Char} # the last two will be winning
    values::Vector{Int64}
    probabilities::Vector{Float64}
    amounteachtime::Int64
end
function printCard(card::ScratchCard)
    println(card.name, ". Price: \$", card.price)
end

struct Prompt
    question::String
    letters::Vector{Char}
    choices::Vector{String}
end

mutable struct Player
    name::String
    balance::Float64
end
function printBalance(player::Player)
    print(player.balance)
end

run(`clear`)

# Code below; structs above

scratchCards = [ScratchCard("Christmas Scratcher", 8, ['Z', 'Y', 'X'], [1, 50, 3], [0.7, 0.05, 0.295], 4),
ScratchCard("Poverty No More!", 1, ['A', 'F', 'P'], [2, 1, 2], [0.2, 0.6, 0.2], 6),
ScratchCard("Worth Your Change", 3, ['Q', 'E', 'P'], [100, 2, 3], [0.01, 0.499, 0.5], 3),
ScratchCard("Win Big Bucks", 4, ['A', 'C', 'E', 'G'], [1, 3, 2, 2], [0.2, 0.3, 0.4, 0.1], 4),
ScratchCard("Dog Show Scratch Card", 3, ['A', 'B', 'C', 'D'], [4, 2, 3, 2], [0.1, 0.3, 0.2, 0.4], 2)]

function getNumberInput()
    try
        in = begin
            i = readline()
            i = parse(Int64, i)
            i
        end
        return in
    catch e
        println("You need to type in a number.")
        return nothing
    end
end

function chooseACard(listOfCards::Vector{ScratchCard}, you::Player) # list -> card
    println("Hello ", you.name)
    for i in 1:length(listOfCards)
        print(i, ". ")
        printCard(listOfCards[i])
    end
    println("Your balance: ", you.balance)
    print("Choose! ")
    chosenCard = getNumberInput()
    if chosenCard <= length(listOfCards)
        return listOfCards[chosenCard]
    else
        println("Your input is out of range.")
        return nothing
    end
end

function statsBool() # void -> boolean
    p::Prompt = Prompt("Would you like to simulate these using statistics or pure randomness?\n(hint: statistics is not on your side)", ['A', 'B'], ["Using statistics", "Using random numbers"])
    println(p.question)
    for i in 1:length(p.choices)
        print(p.letters[i], ". ")
        println(p.choices[i])
    end
    print("Choose: ")

    choice::Bool = begin
        i = readline()
        if only(i) in p.letters
            if i=="A"
                return true
            else
                return false
            end
        else
            print("You entered an invalid choice.")
            return nothing
        end
    end
end

function getExpectedValue(scratchCard::ScratchCard)
    # here i will account for the fact that values and probabilities not being the same length would throw an error
    # find the shortest array of the two
    v::Vector{Int64} = scratchCard.values
    p::Vector{Float64} = scratchCard.probabilities
    len::Int8 = 0
    if length(v) < length(p)
        len = length(v)
    else 
        len = length(p)
    end

    # then, the probabilites need to sum to 1.0, but that might not be the case, so I'll need to normalize the sum
    total = 0
    for i in p
        total+=i
    end

    weightedsum = 0
    # now i iterate over both lists
    for i in 1:len
        weightedsum += v[i]*p[i]/total
    end

    return round(weightedsum)
end

function simulate(scratchCard::ScratchCard, option::Bool) # ScratchCard -> Int64 (winnings)
    # implement this function
    if option # use stats
        return getExpectedValue(scratchCard) # this isnt really the expected value
    else # don't use stats
        # need to randomize
        total = 0
        for i in scratchCard.probabilities
            total+=i
        end

        winnings::Int64 = 0
        s = scratchCard.letters
        winningtile = s[rand(1:length(s))]
        randoms::Array{Float64,2} = rand(Uniform(0.0,total),1,scratchCard.amounteachtime)
        associatedcash::Array{Float64,2} = rand(Uniform(1.0,length(scratchCard.values)),1,scratchCard.amounteachtime)
        println("Winning tile: ", winningtile, ". You only win if you get this one!")
        for j in 1:length(randoms)
            partialsum = 0
            target = randoms[j]
            pr = scratchCard.probabilities
            found = false

            for k in 1:length(pr)
                partialsum+=pr[k]
                if partialsum > target && !found
                    found = true
                    l = scratchCard.letters[k]
                    aa = associatedcash[j]
                    if l == winningtile
                        println(l," ", scratchCard.values[Int64(round(aa))], " - win! You've won \$", scratchCard.values[Int64(round(aa))], "!")
                        winnings+=scratchCard.values[Int64(round(aa))]
                    else
                        println(l," ", scratchCard.values[Int64(round(aa))])
                    end
                end
            end
        end
        return winnings
    end

    return -1
end

function cycle(player::Player) # void -> Int (winnings)
    winnings::Int64 = 0
    chosenCard::ScratchCard = chooseACard(scratchCards, player)
    print("How many? ")
    quantity::Int64 = getNumberInput()
    println()
    println("You purchased ", quantity, " ", chosenCard.name, " cards.")
    # need to take money from balance
    player.balance -= chosenCard.price*quantity
    println("Your new balance is \$", player.balance)
    println()

    b::Bool = statsBool()
    println()

    for i in 1:quantity
        win::Int64 = simulate(chosenCard, b)
        pr::Int64 = chosenCard.price
        # change won/gain to depend on positive/negative
        println("(", i, "/", quantity, ") You won \$", win, " for a net gain of \$", (win-pr))
        println("")
        winnings += (win-pr)
    end

    print("In total, you grossed \$", winnings, ". ")
    if winnings > 0
        println("Congrats!")
    else
        println("Gambling is stupid.")
    end

    return winnings
end

pl = Player("A", 100)

while true
    pl.balance = pl.balance + cycle(pl)
    print("Continue? (y/n) ")
    cont = readline()
    if cont == "N" || cont == "n"
        break
    end
end