"
I verify that {{gtClass:GtGitStatusElement}} does not accumulate pending status futures when its repository is modified repeatedly, and that a detached element is refreshed once it is attached again.
"
Class {
	#name : #GtGitStatusElementExamples,
	#superclass : #Object,
	#category : #'GToolkit4Git-Examples'
}

{ #category : #examples }
GtGitStatusElementExamples >> burstOfModificationsDoesNotAccumulateStatusFutures [
	<gtExample>
	<return: #BlScripter>
	| aRepository aScripter |
	aRepository := GtGitStatusElementStubRepository new.
	aScripter := BlScripter new.
	aScripter
		substep: 'Show status element'
		do: [ :aStep | 
			aStep set
				label: 'Initialize UI';
				element: [ self newStatusElementOn: aRepository ];
				play ].
	aScripter
		substep: 'Modifications while status is blocked'
		do: [ :aStep | 
			aStep
				doStep: [ :s | 
					s
						label: 'Wait for the first status request';
						block: [ :anElement | 
							self
								assert: (self waitFor: [ aRepository statusModelCallCount = 1 ] pulsing: aScripter)
								description: 'The first status request did not start' ];
						onSelf ].
			aStep
				doStep: [ :s | 
					s
						label: 'Modify the repository in 50 frames';
						block: [ :anElement | 
							50 timesRepeat: [ 
								aRepository announceModified.
								aScripter pulse.
								(Delay forMilliseconds: 20) wait ] ];
						onSelf ].
			aStep
				assertStep: [ :s | 
					s
						label: 'Assert bounded number of pending futures';
						satisfies: [ :anElement | 
							aRepository statusModelCallCount = 1 and: [ self pendingFuturesInExampleGroup <= 2 ] ];
						onSelf ] ].
	aScripter
		substep: 'Release the worker'
		do: [ :aStep | 
			aStep
				doStep: [ :s | 
					s
						label: 'Release and wait for the status';
						block: [ :anElement | 
							aRepository releaseAllStatusModels.
							self
								assert: (self waitFor: [ anElement childrenCount = 1 and: [ self pendingFuturesInExampleGroup = 0 ] ] pulsing: aScripter)
								description: 'The status was not shown' ];
						onSelf ].
			aStep
				assertStep: [ :s | 
					s
						label: 'Assert only the blocked and the latest requests ran';
						satisfies: [ :anElement | aRepository statusModelCallCount = 2 ];
						onSelf ] ].
	^ aScripter
]

{ #category : #examples }
GtGitStatusElementExamples >> detachedElementRefreshesWhenAttached [
	<gtExample>
	<return: #BlScripter>
	| aRepository aStatusElement aScripter |
	aRepository := GtGitStatusElementStubRepository new.
	aRepository releaseAllStatusModels.
	aStatusElement := self newStatusElementOn: aRepository.
	5 timesRepeat: [ aRepository announceModified ].
	self assert: aRepository statusModelCallCount equals: 0.

	aScripter := BlScripter new.
	aScripter
		substep: 'Attach status element'
		do: [ :aStep | 
			aStep set
				label: 'Initialize UI';
				element: [ aStatusElement ];
				play ].
	aScripter
		substep: 'Refresh after attaching'
		do: [ :aStep | 
			aStep
				doStep: [ :s | 
					s
						label: 'Wait for the status';
						block: [ :anElement | 
							self
								assert: (self waitFor: [ anElement childrenCount = 1 ] pulsing: aScripter)
								description: 'The status was not shown after attaching' ];
						onSelf ].
			aStep
				assertStep: [ :s | 
					s
						label: 'Assert a single status request';
						satisfies: [ :anElement | aRepository statusModelCallCount = 1 ];
						onSelf ] ].
	^ aScripter
]

{ #category : #examples }
GtGitStatusElementExamples >> elementDetachedDuringPendingStatusIsRefreshedWhenAttached [
	<gtExample>
	<return: #BlScripter>
	| aRepository aStatusElement aContainer aScripter |
	aRepository := GtGitStatusElementStubRepository new.
	aStatusElement := self newStatusElementOn: aRepository.
	aContainer := BlElement new
			layout: BlFrameLayout new;
			constraintsDo: [ :c | 
				c horizontal matchParent.
				c vertical matchParent ];
			addChild: aStatusElement;
			yourself.
	aScripter := BlScripter new.
	aScripter
		substep: 'Show container'
		do: [ :aStep | 
			aStep set
				label: 'Initialize UI';
				element: [ aContainer ];
				play ].
	aScripter
		substep: 'Detach while status is pending'
		do: [ :aStep | 
			aStep
				doStep: [ :s | 
					s
						label: 'Wait for the status request, detach, modify and release';
						block: [ :anElement | 
							self
								assert: (self waitFor: [ aRepository statusModelCallCount = 1 ] pulsing: aScripter)
								description: 'The status request did not start'.
							aStatusElement removeFromParent.
							aRepository announceModified.
							aRepository releaseAllStatusModels.
							(Delay forMilliseconds: 300) wait.
							3 timesRepeat: [ aScripter pulse ] ];
						onSelf ].
			aStep
				assertStep: [ :s | 
					s
						label: 'Assert no new request while detached';
						satisfies: [ :anElement | aRepository statusModelCallCount = 1 ];
						onSelf ] ].
	aScripter
		substep: 'Attach again'
		do: [ :aStep | 
			aStep
				doStep: [ :s | 
					s
						label: 'Add status element back and wait for the status';
						block: [ :anElement | 
							anElement addChild: aStatusElement.
							self
								assert: (self waitFor: [ aRepository statusModelCallCount = 2 and: [ aStatusElement childrenCount = 1 ] ] pulsing: aScripter)
								description: 'The status was not refreshed after attaching' ];
						onSelf ] ].
	^ aScripter
]

{ #category : #support }
GtGitStatusElementExamples >> newStatusElementOn: aRepository [
	"Use a dedicated worker group, so that examples do not queue behind other Git futures."

	^ GtGitStatusElement new
		futureConfiguration: (AsyncFutureExecutionConfiguration new
				customGroup: #GitStatusElementExamples;
				lowPriority);
		repository: aRepository;
		yourself
]

{ #category : #support }
GtGitStatusElementExamples >> pendingFuturesInExampleGroup [
	"Number of futures queued on the worker of the dedicated example group."

	^ AsyncFutureThreadPool current workerArray
		detect: [ :eachWorker | eachWorker name asString = 'GitStatusElementExamples' ]
		ifFound: [ :aWorker | aWorker localItemArray size ]
		ifNone: [ 0 ]
]

{ #category : #support }
GtGitStatusElementExamples >> waitFor: aConditionBlock pulsing: aScripter [
	"Pulse the scripter space until the condition holds, at most five seconds."

	100 timesRepeat: [ 
		aConditionBlock value ifTrue: [ ^ true ].
		aScripter pulse.
		(Delay forMilliseconds: 50) wait ].
	^ aConditionBlock value
]
