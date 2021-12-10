Class {
	#name : #GtLepiterPagesDefinition,
	#superclass : #GtLepiterDefinition,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterPagesDefinition >> icon [
	^ self iconNamed: #emptyPackage
]

{ #category : #initialization }
GtLepiterPagesDefinition >> initialize [
	super initialize.
	self name: 'pages'.
]
