do

function run(msg, matches)
  return "کس ننت, " .. matches[1]
end

return {
  description = "Says hello to someone", 
  usage = "say hello to [name]",
  patterns = {
    "^بگو کس ننت (.*)$",
    "^بگو کس ننت (.*)$",
	"^فحش بده به (.*)$"
  }, 
  run = run 
}

end