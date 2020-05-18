#lang racket

(require discord-bot)
(require discourse-bot)


(define pipeline-post-id 91)

(define (jobs-list cmd)
  (~a
    "Here are the current job listings:\n\n"
    (string-join
      (map show-job-listing 
	   (topic-id->video-editing-job-listing-posts pipeline-post-id))
      "\n")))

(define (jobs-take cmd job-id)
  (let ([u (job-id->video-editing-job-topic-url (string->number job-id))]) 
       (make-post-on-topic! u
			    (~a "[Video Editing Job Taken]\n"
				"Someone" ;TODO: Make current user a parameter
				" started working on this job." )) 
       (~a
	 "Cool, you just took job #" job-id ".  I posted here so everyone will know you're working on it:\n\n"

	 u  

	 "\n\nWhen you've produced a video and given it a DONE-URL (e.g. by uploading to YouTube), I'll mark your work as complete if you type:\n\n"

	 "! jobs done " job-id " DONE-URL")))

(define (jobs-done cmd job-id done-url)
  (let ([u (job-id->video-editing-job-topic-url (string->number job-id))]) 
       (make-post-on-topic! u
			    (~a "[Video Editing Job Submitted] \n"
				"Someone" ;TODO: Make current user a parameter
				" finished working on this job.  Here is their submission\n"  done-url)) 
       (~a
	 "Cool, you just finished job #" job-id ".  I'm just a bot, so I'm not smart enough to check your work for you.  But I posted here so everyone will know you've finished:\n\n"

	 u )))

(define (jobs cmd [arg #f] [arg2 #f])
  (cond
    [(string=? cmd "list") (jobs-list cmd) ]
    [(string=? cmd "take") (jobs-take cmd arg) ]
    [(string=? cmd "done") (jobs-done cmd arg arg2) ]
    [else
      (~a "Echo: " cmd " " arg)]))


(define b
  (bot
    ["help" (thunk* "Find my docs here!\n\nhttps://forum.metacoders.org/t/documentation-video-editing-bot/96")]
    ["jobs" jobs]
    [else (const "")]
    ))


;A job listing is a post in a Video Editing Pipeline Topic
(define (show-job-listing l)
  (~a
    "#" (id l) " " (listing->video-editing-job-post-url l) 
    ))

(define (listing->video-editing-job-post-url l)
  (url (first (link-counts l))))

(define video-editing-job-post-bot-tag
  "[Video Editing Job Listing]")

(define (video-editing-job-listing-post? p)
  (string-contains? (cooked p)
		    video-editing-job-post-bot-tag))

(define (topic-id->video-editing-job-listing-posts i)
  (filter video-editing-job-listing-post?
	  (posts
	    (post-stream
	      (get-topic i)))))


(define (job-id->video-editing-job-topic-url job-id)
  (first (links (get-post job-id))))

(launch-bot b)
