(defun do-agenda-load ()
 ""
 (interactive)
 (see
  (freekbs2-util-data-dedumper
   (uea-query-agent-raw "" "Verber"
    (freekbs2-util-data-dumper
     (list
      (cons "Command" "plan")
      (cons "Name" "CYCLE_WEEKLY2")
      (cons "Timing"
       (list
	(cons "StartDateString" "2016-03-01_00:00:00")
	(cons "EndDateString" "2016-03-01_23:59:59")
	(cons "Units" "0000-00-01_00:00:00")
	)
       )
      (list "Verber::Federated::Util::Date1"
       (cons "Flags"
	(list
	 (cons "Date" "1")
	 (cons "DayOfWeek" "1")
	 (cons "Today" "1")
	 )
	)
       )
      )
     )
    )
   )
  )
 )

(provide 'do-agenda)
