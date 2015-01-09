def admin?
  `net session`
  return true if $?==0
  return false
end
