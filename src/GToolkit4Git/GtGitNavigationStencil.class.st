Class {
	#name : #GtGitNavigationStencil,
	#superclass : #BrStencil,
	#instVars : [
		'navigationModel'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #accessing }
GtGitNavigationStencil >> announce: anObject [ 
	self announcer announce: anObject
]

{ #category : #announcer }
GtGitNavigationStencil >> announcer [
	^ navigationModel announcer
]

{ #category : #accessing }
GtGitNavigationStencil >> create [

	<return: #BrColumnedList>
	^ GtPhlowColumnedListView new
		  updateWhen: IceRepositoryAnnouncement in: [ Iceberg announcer ];
		  items: [ 
			  self navigationModel repositories collect: [ :eachIceRepository | 
					  GtGitRepository new repository: eachIceRepository ] ];
		  send: [:repo | 	self
		announce:
			(GtGitRepositorySelected new
				repository: repo)];
		  column: 'Repository' translated text: [ :each | 
			  | description |
			  description := each name asRopedText.
			  each isModified ifTrue: [ 
					  description := ('*' , description asString) asRopedText 
						                 foreground: (Color r: 0 g: 0.5 b: 0) ].
			  description ]
		  width: 200;
		  column: 'Branch' translated
		  text: [ :each | each headDescription ]
		  width: 200;
		  column: 'Status' translated
		  text: [ :each | each status ]
		  width: 200
]

{ #category : #accessing }
GtGitNavigationStencil >> navigationModel [
	^ navigationModel
]

{ #category : #accessing }
GtGitNavigationStencil >> navigationModel: aGtGitNavigationModel [
	navigationModel := aGtGitNavigationModel
]
