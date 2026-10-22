Class {
	#name : #GtGitStatusElement,
	#superclass : #BlElement,
	#instVars : [
		'session',
		'futureConfiguration',
		'repository',
		'statusTask',
		'statusPromise',
		'statusUpdater'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #initialization }
GtGitStatusElement >> defaultFutureConfiguration [
	^ AsyncFutureExecutionConfiguration new 
		customGroup: #Git;
		lowPriority
]

{ #category : #private }
GtGitStatusElement >> finishRefreshWith: aStatuses task: aTaskAction [
	"I am evaluated in a UI process."

	statusTask lock: [ :aCurrentTask |
		aTaskAction == aCurrentTask ifFalse: [ ^ self ].
		statusTask value: nil.
		statusPromise := nil ].
	
	aStatuses
		ifNotNil: [ self removeChildren.
			aStatuses do: [ :aStatus | self addChild: aStatus asElement ] ]
]

{ #category : #accessing }
GtGitStatusElement >> futureConfiguration [
	<return: #AsyncFutureExecutionConfiguration>
	^ futureConfiguration ifNil: [ 
		futureConfiguration := self defaultFutureConfiguration ]
]

{ #category : #accessing }
GtGitStatusElement >> futureConfiguration: aAsyncFutureExecutionConfiguration [
	futureConfiguration := aAsyncFutureExecutionConfiguration
]

{ #category : #accessing }
GtGitStatusElement >> initialize [
	super initialize.

	self
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c | 
			c vertical fitContent.
			c horizontal fitContent ].
			
	statusUpdater := BrElementUpdater new element: self selector: #refreshStatus.
	statusPromise := nil.
	statusTask := AsyncMutex for: nil.
]

{ #category : #accessing }
GtGitStatusElement >> onRepositoryModified: anAnnouncement [
	statusUpdater requestUpdate
]

{ #category : #private }
GtGitStatusElement >> refreshStatus [
	"I am evaluated by the updater in a UI process.
	I cancel the previous status future, if it is still pending, and start a new one, so superseded futures do not pile up.
	The last started future enqueues a task that shows its status. Tasks of superseded futures are ignored, see {{gtMethod:GtGitStatusElement>>#finishRefreshWith:task:}}."

	| aRepository aFuture |
	aRepository := repository.
	statusPromise
		ifNotNil: [ :aPromise | 
			statusPromise := nil.
			aPromise cancelSoft ].
	aFuture := [ aRepository statusModel ] asAsyncFuture.
	aFuture := aFuture
			on: Error
			do: [ :anError | 
				anError emit.
				nil ].
	aFuture := aFuture
			map: [ :aStatus | 
				| aTask |
				aTask := BlTaskAction new.
				aTask action: [ self finishRefreshWith: aStatus task: aTask ].
				statusTask value: aTask.
				self enqueueTask: aTask ].
	statusPromise := aFuture await: self futureConfiguration
]

{ #category : #accessing }
GtGitStatusElement >> repository: aRepository [
	session ifNotNil: [ ^ self ].
	session := Smalltalk session.
	repository := aRepository.
	self subscribeTo: aRepository viewModel.
	statusUpdater requestUpdate
]

{ #category : #private }
GtGitStatusElement >> subscribeTo: aViewModel [
	aViewModel weak when: GtRepositoryModified send: #onRepositoryModified: to: self
]
