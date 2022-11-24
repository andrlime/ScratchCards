function takeNumberInput(min::Int64, max::Int64) # number, number -> user -> number
    try
        in = begin
            i = readline()
            i = parse(Int64, i)
            i
        end
        if in <= max && in >= min
            return in
        else
            print("Your number is not in range. Try again: ")
            return takeNumberInput(min, max)
        end
    catch e
        print("You need to type in a number. Try again: ")
        return takeNumberInput(min, max)
    end
end

function generateNumbers(count::Int64, min::Int64, max::Int64) # void -> Vector{Int64}
    list::Vector{Int64} = Vector{Int64}()
    for _ in 1:count
        push!(list, rand((min:max)))
    end

    return list
end

function countMatches(list1::Vector{Int64}, list2::Vector{Int64})
    return length(intersect(list1, list2))
end

function cycle(winningwhitenumbers::Vector{Int64}, winningpowerball::Int64) # void -> number
    # doesn't support powerplay and double play
    # source: https://www.lottoamerica.com/powerball/prizes
    words::Vector{String} = ["first", "second", "third", "fourth", "fifth"]
    chosennumbers::Vector{Int64} = Vector{Int64}()
    println("Choose your five white ball numbers from 1-69.")
    for i in words
        print("Choose your ", i, " number (1-69): ")
        push!(chosennumbers, takeNumberInput(1, 69))
    end

    print("Choose your powerball number from 1-26: ")
    chosenpb = takeNumberInput(1, 26)
    # count number of matches between both lists
    pbmatch = (chosenpb == winningpowerball)
    whmatches = countMatches(chosennumbers, winningwhitenumbers)

    println()
    println("Your guesses were ", chosennumbers, " and ", chosenpb)
    println("You matched ", whmatches, " whites and you ", (pbmatch ? "did" : "didn't"), " match the powerball")
    
    if pbmatch
        if whmatches == 5
            return -30000
        elseif whmatches == 4
            return 50000
        elseif whmatches == 3
            return 100
        elseif whmatches == 2
            return 7
        else
            return 4
        end
    else
        if whmatches == 5
            return 1000000
        elseif whmatches == 4
            return 100
        elseif whmatches == 3
            return 7
        elseif whmatches == 2
            return 0
        elseif whmatches == 1
            return 0
        else
            return 0
        end
    end
end

mutable struct Player
    name::String
    balance::Float64
end
function printBalance(player::Player)
    print(player.balance)
end

run(`clear`)
pl = Player("A", 100000000)
jackpot = 20000000
while true
    print("Your balance is \$", pl.balance, ". How many tickets do you want? \$2 each. ")
    amount = takeNumberInput(1, Int64(round(pl.balance/2)))
    pl.balance -= amount*2
    winningwhitenumbers = generateNumbers(5, 1, 69)
    winningpowerball = generateNumbers(1, 1, 26)[1]

    for i in 1:amount
        print("(", i, "/", amount, ") ")
        winnings = cycle(winningwhitenumbers, winningpowerball)
        if winnings == -30000
            winnings = jackpot
        else
            global jackpot*=1.001
        end
        println("You just won \$", winnings, " for a net gain of \$", (winnings-2))
        println()
        pl.balance = pl.balance + winnings

        if winnings == jackpot
            break
        end
    end

    println("Winning numbers were ", winningwhitenumbers, " and ", winningpowerball)
    print("Continue? (y/n) ")
    cont = readline()
    if cont == "N" || cont == "n"
        break
    end
end