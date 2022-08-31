Class {
	#name : #GtGitProjectLoader,
	#superclass : #Object,
	#instVars : [
		'baseline',
		'repository'
	],
	#category : #'GToolkit4Git-Loader'
}

{ #category : #accessing }
GtGitProjectLoader >> baseline [

	^ baseline
]

{ #category : #accessing }
GtGitProjectLoader >> baseline: anObject [

	baseline := anObject
]

{ #category : #accessing }
GtGitProjectLoader >> check [
]

{ #category : #accessing }
GtGitProjectLoader >> credentialStore [
	^ IceCredentialStore current
]

{ #category : #accessing }
GtGitProjectLoader >> defaultSshCredential [
	^ self credentialStore defaultSSHCredential
]

{ #category : #'gt - extensions' }
GtGitProjectLoader >> gtChecksFor: aView [
	<gtView>
	^ aView explicit
		title: 'Checks';
		priority: 2;
		actionUpdateButton;
		stencil: [ | actions actionStream element |
			actions := GtAdvice adviceFor: self.
			actionStream := (actions asAsyncStream select: [ :each | each hasAdvice ])
					cached.
			element := BrSimpleList new.
			element padding: (BlInsets all: 3).
			element vFitContentLimited.
			element hExact: 300.
			element
				itemsProvider: (BrStreamItemsProvider new
						preloadAmount: 1;
						stream: actionStream asyncSimilarCopy);
				stencil: [ :anAdvice | anAdvice buildElementFor: element ].
			element ]
]

{ #category : #'gt - advice' }
GtGitProjectLoader >> gtExistingRepositoryLocation: aGtAdvice [
	<gtAdvice>
	^ aGtAdvice item
		priority: 4;
		description: [ :aLoader | 'Repository location exists' asRopedText ];
		compute: [ self repositoryLocationExists ifTrue: [ self ] ]
]

{ #category : #'gt - extensions' }
GtGitProjectLoader >> gtInfo [
	^ OrderedDictionary new
		at: 'Baseline' put: self baseline;
		at: 'Repository' put: (self repository ifNotNil: #uri);
		yourself
]

{ #category : #'gt - extensions' }
GtGitProjectLoader >> gtInfoFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Info';
		priority: 1;
		items: [ self gtInfo associations ];
		column: 'Name' text: #key;
		column: 'Value'
			text: #value
			weight: 2;
		send: #value
]

{ #category : #'gt - advice' }
GtGitProjectLoader >> gtMissingBaseline: aGtAdvice [
	<gtAdvice>
	^ aGtAdvice item
		priority: 1;
		description: [ :aLoader | 'Baseline name is missing' asRopedText ];
		compute: [ self isBaselineDefined ifFalse: [ self ] ]
]

{ #category : #'gt - advice' }
GtGitProjectLoader >> gtMissingRepository: aGtAdvice [
	<gtAdvice>
	^ aGtAdvice item
		priority: 2;
		description: [ :aLoader | 'Repository name is missing' asRopedText ];
		compute: [ self isRepositoryDefined ifFalse: [ self ] ]
]

{ #category : #'gt - advice' }
GtGitProjectLoader >> gtMissingSshCredential: aGtAdvice [
	<gtAdvice>
	^ aGtAdvice item
		priority: 3;
		description: [ :aLoader | 'Missing default SSH credential' asRopedText ];
		compute: [ self isDefaultSshCredentialDefined ifFalse: [ IceCredentialStore current ] ]
]

{ #category : #testing }
GtGitProjectLoader >> isBaselineDefined [
	^ self baseline isNotNil
		and: [ self baseline isString and: [ self baseline isNotEmpty ] ]
]

{ #category : #testing }
GtGitProjectLoader >> isDefaultSshCredentialDefined [
	^ self defaultSshCredential isPresent
]

{ #category : #testing }
GtGitProjectLoader >> isRepositoryDefined [
	^ self repository isNotNil and: [ self repository isDefined ]
]

{ #category : #accessing }
GtGitProjectLoader >> repository [

	^ repository
]

{ #category : #accessing }
GtGitProjectLoader >> repository: aString [
	repository := GtGitProjectRepositoryUri new uri: aString
]

{ #category : #testing }
GtGitProjectLoader >> repositoryLocationExists [
	^ self isRepositoryDefined and: [ self repository icebergDirectoryExists ]
]
