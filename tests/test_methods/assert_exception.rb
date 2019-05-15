def assert_exception(proc, msg)
  raised_exception = false
  begin
    proc.call
  rescue => e
    #puts e
    raised_exception = true
  end
  raise msg unless(raised_exception)
end