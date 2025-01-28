Class {
	#name : #GtGitRemoteRepositoryForm,
	#superclass : #Object,
	#instVars : [
		'dropdown',
		'onCreated',
		'url'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitRemoteRepositoryForm >> asElement [
	^ (self asGtMagritteViewModel
		onElementCreated: [ :aFrame | 
			BlFocusFinder new
				direction: BlFocusSearchDirectionForward new;
				root: aFrame;
				referenceElement: nil;
				nextFocusDo: #requestFocus ifNone: [  ] ]) asElement
		padding: ((BlInsets all: 10) withRight: 5)
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> dropdown [
	^ dropdown
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> dropdown: anObject [
	dropdown := anObject
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> exampleText [
	^ 'https://example.com or git@githost.com:remotePath.git'
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> executeAsAsyncJob: block [
	| gtJob |
	gtJob := GtJob block: block.
	GtNotificationJob new
		summaryClass: GtSingleJobNotificationSummary;
		job: gtJob;
		registerNotifications.
	^ [ gtJob run ] asAsyncPromise
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> initialize [
	url := '' asRopedText
			attribute: (BrGhostTextAttribute
					for: (self exampleText asRopedText glamorousFormEditorCodeFontAndSize
							foreground: Color lightGray))
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		onSuccessCallback: [ self
				executeAsAsyncJob: [ :job | 
					job label: 'Cloning...'.
					[ | creator repo |
					creator := IceRepository repositoryClass creatorClass new
							remote: (IceGitRemote url: self url);
							location: self projectLocation.
					repo := creator createRepository.
					repo register.
					dropdown
						ifNotNil: [ :aDropdown | 
							aDropdown
								enqueueTask: (BlTaskAction new action: [ aDropdown dispatchEvent: BrDropdownHideWish new ]) ].
					self onCreated value: repo ] on: Error do: #debug ] ];
		beEnabledOnValidOverallStatus
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> onCreated [
	^ onCreated
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> onCreated: anObject [
	onCreated := anObject
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> projectLocation [
	| anUrl owner project |
	anUrl := url copyReplaceAll: 'git@github.com:' with: ''.
	anUrl := anUrl copyReplaceAll: '.git' with: ''.
	owner := (anUrl findTokens: '/') first.
	project := (anUrl findTokens: '/') last.
	^ IceLibgitRepository repositoriesLocation / owner / project
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> url [
	^ url
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> url: anObject [
	url := anObject
]

{ #category : #accessing }
GtGitRemoteRepositoryForm >> urlDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'URL';
		priority: 1;
		accessor: #url;
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousCodeFontAndSmallSize ]
]
