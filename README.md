This script will start washing black_money into cash when the player enters the command /starttip<br />
black_money and cash are items in this case, because that's how my server operates.  If you want to use money instead of items, then just edit the if statement starting on line 25 in server/main.lua<br /><br />
From this:<br />
<pre>
                  if currentCurrency and currentCurrency.amount >= 10 then
                    -- Remove the total amount of black_money from the player.
                    Player.Functions.RemoveItem(Config.Currency, 10)
                    -- Give 6 dollars cash to the original player.
                    Player.Functions.AddMoney('cash', 6)
                    -- Give 4 dollars black_money to the dancer/target player.
                    Target.Functions.AddItem(Config.Currency, 4)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Not enough currency to continue tipping.', 'error')
                    break
                end
</pre>
<br />
To this:<br />
<pre>
                if currentCurrency and currentCurrency.amount >= 10 then
                    -- Remove the total amount of black_money from the player.
                    Player.Functions.RemoveMoney(Config.Currency, 10)
                    -- Give 6 dollars cash to the original player.
                    Player.Functions.AddMoney('cash', 6)
                    -- Give 4 dollars black_money to the dancer/target player.
                    Target.Functions.AddMoney(Config.Currency, 4)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Not enough currency to continue tipping.', 'error')
                    break
                end
</pre>
<br />
Any other help feel free to ask.
