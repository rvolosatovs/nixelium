todo_count=$(wc -l < "$HOME/TODO")
if [ ${todo_count} -gt 0 ]; then
    echo "TODO count: ${todo_count}" >&2
    echo "" >&2
    cat  "$HOME/TODO" >&2
    echo "" >&2
else
    echo "Good job, your todo list is empty!" >&2
fi
