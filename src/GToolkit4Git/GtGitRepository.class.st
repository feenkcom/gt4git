Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'repository',
		'announcer',
		'isSubscribed'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #announcer }
GtGitRepository >> announcer [
	<return: #Announcer>
	^ announcer
]

{ #category : #'api - repository' }
GtGitRepository >> changes [
	^ self isModified
		ifTrue: [ self workingCopy diffToReferenceCommit treeToShow children ]
		ifFalse: [ Array empty ]
]

{ #category : #'api - actions' }
GtGitRepository >> executeCommit: aCommitMessage [
	|diff|
	diff := self repository workingCopyDiff.
	self workingCopy 
		commitChanges: diff
		withMessage: aCommitMessage
		force: false.
	Iceberg announcer announce: (IceRepositoryModified for: self repository).
]

{ #category : #'api - actions' }
GtGitRepository >> fetch [
	self repository fetch.
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtChanges2For: aView context: aContext [
	<gtView>
	"<gtRepositoryView>"
	self hasChanges ifFalse: [ ^ aView empty ].
	^ aView tree
		title: 'Changes 2';
		items: [ self workingCopy diffToReferenceCommit treeToShow children ];
		updateWhen: IceRepositoryModified in: Iceberg announcer;
		children: #children;
		expandUpTo: 3;
		priority: 11;
		stencil: [ :anIceNode |
			BlElement new
				layout: BlLinearLayout horizontal;
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical fitContent ];
				margin: (BlInsets all: 3);
				constraintsDo: [ :c | c vertical fitContent ];
				aptitude:
					(BrGlamorousWithContextMenuAptitude
						content: [ BrGlamorousSimpleContextMenuContent new
								items:
									{('Revert changes'
										->
											[ :e | self workingCopy diffToReferenceCommit revertChanges: anIceNode ])};
								yourself ]);
				addChild:
					(anIceNode value icon asElement
						constraintsDo: [ :c | c linear horizontal alignCenter ]);
				addChild:
					(BrLabel new
						aptitude: BrGlamorousLabelAptitude;
						text: anIceNode key asString asRopedText;
						padding:
							(BlInsets
								top: 0
								left: 6
								bottom: 0
								right: 3);
						constraintsDo: [ :c | c linear horizontal alignCenter ]) ];
		actionDropdownButtonLabel: 'Commit'
			tooltip: 'Commit changes'
			content: [ :aDropdown :aTarget | 
			| editor button |
			
			editor := BrEditor new
				hMatchParent;
				vFitContentLimited;
				aptitude: BrGlamorousRegularEditorAptitude;
				text: self currentCommitMessage.
			editor selecter all; select.
			
			button := BrButton new.
			button
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons accept;
				label: 'Commit';
				disabled: editor text isEmpty;
				action: [ 
					self recentCommitMessage: editor text asString.
					self executeCommit: editor editor text asString.
					button disable.
					self resetCurrentCommitMessage.
					aDropdown enqueueTask: (BlTaskAction new
						action: [ 
							aDropdown dispatchEvent: (BrDropdownHideWish new anchor: aDropdown).
							aDropdown phlow fireUpdateWish ]) ].

			editor editor
				when: BrTextEditorModifiedEvent
				do: [ :anEvent | button disabled: anEvent text isEmpty ].

			BrVerticalPane new
				hExact: 400;
				vFitContentLimited;
				padding: (BlInsets all: 10);
				addChildren: { editor . button } ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtChangesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	| aViewModel |

	self hasChanges ifFalse: [ ^ aView empty ].
	
	aViewModel := aContext
		at: #repositoryViewModel
		ifAbsentPut: [ GtGitRepositoryViewModel new repositoryModel: self ].
	
	^ aView explicit
		title: 'Changes';
		priority: 10;
		stencil: [ GtGitRepositoryChangesElement new 
			margin: (BlInsets all: 10);
			repositoryViewModel: aViewModel ];
		actionDropdownButtonLabel: 'Commit'
			tooltip: 'Commit changes'
			content: [ :aDropdown :aTarget | 
			| editor button |
			
			editor := BrEditor new
				hMatchParent;
				vFitContentLimited;
				aptitude: BrGlamorousRegularEditorAptitude;
				text: aViewModel commitMessage.
			editor selecter all; select.
			
			button := BrButton new.
			button
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: BrGlamorousVectorIcons accept;
				label: 'Commit';
				disabled: editor text isEmpty;
				action: [ 
					aViewModel executeCommit: editor editor text asString.
					button disable.
					aDropdown enqueueTask: (BlTaskAction new
						action: [ 
							aDropdown dispatchEvent: (BrDropdownHideWish new anchor: aDropdown).
					button phlow fireUpdateWish ]) ].

			editor editor
				when: BrTextEditorModifiedEvent
				do: [ :anEvent | 
					button disabled: anEvent text isEmpty.
					aViewModel commitMessage: editor text asString. ].

			BrVerticalPane new
				hExact: 400;
				vFitContentLimited;
				padding: (BlInsets all: 10);
				addChildren: { editor . button } ]
]

{ #category : #accessing }
GtGitRepository >> gtCommitsFor: aView [
	<gtView>
	<gtRepositoryView>
	self repository repositoryDirectory ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Commits';
		object: [ self repository branch ];
		view: #gtCommitsFor:
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtPackagesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	self hasWorkingCopy ifFalse: [ ^ aView empty ].
	^ self repository workingCopy gtPackagesFor: aView
]

{ #category : #'api - testing' }
GtGitRepository >> hasChanges [
	^ self hasWorkingCopy and: [ 
		self isModified "and: [  
			self workingCopy diffToReferenceCommit treeToShow children isNotEmpty ]" ]
]

{ #category : #'api - testing' }
GtGitRepository >> hasRepository [
	^ self repository isNotNil
]

{ #category : #'api - testing' }
GtGitRepository >> hasWorkingCopy [
	^ self hasRepository and: [ self repository workingCopy isNotNil ]
]

{ #category : #'api - repository' }
GtGitRepository >> headDescription [
	^ self repository ifNotNil: #headDescription ifNil: [ '<missing>' ]
]

{ #category : #initialization }
GtGitRepository >> initialize [
	super initialize.
	announcer := Announcer new.
	isSubscribed := false.
]

{ #category : #'api - testing' }
GtGitRepository >> isModified [
	^ self hasWorkingCopy and: [ self workingCopy isModified ]
]

{ #category : #'api - repository' }
GtGitRepository >> name [
	^ self repository ifNotNil: #name ifNil: [ '<missing>' ]
]

{ #category : #'private - announcement handling' }
GtGitRepository >> onRepositoryModifiedAnnouncement: anAnnouncement [
	anAnnouncement repository = self repository ifTrue: [ ^ self ].
	
	self announce: anAnnouncement
]

{ #category : #printing }
GtGitRepository >> printOn: aStream [
	super printOn: aStream.
	self repository ifNil: [ ^ self ].
	
	aStream 
		nextPut: $(;
		nextPutAll: self repository name;
		nextPut: $)
]

{ #category : #accessing }
GtGitRepository >> pull [
	^ self repository pull
]

{ #category : #accessing }
GtGitRepository >> push [

	| res |
	res := self repository push.
	Iceberg announcer announce:
		(IceRepositoryModified for: self repository).
	^ res
]

{ #category : #'api - accessing' }
GtGitRepository >> repository [
	^ repository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository: aRepository [

	repository == aRepository ifTrue: [ ^ self ].
	
	repository := aRepository.
	
	isSubscribed ifTrue: [ ^ self ].
	
	Iceberg announcer weak
		when: IceRepositoryModified
		send: #onRepositoryModifiedAnnouncement:
		to: self.
]

{ #category : #'api - repository' }
GtGitRepository >> workingCopy [
	^ self repository workingCopy
]
