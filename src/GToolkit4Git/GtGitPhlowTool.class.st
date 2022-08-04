Class {
	#name : #GtGitPhlowTool,
	#superclass : #GtPhlowTool,
	#category : #'GToolkit4Git-Tools'
}

{ #category : #accessing }
GtGitPhlowTool >> asElementDo: aBlock [
	^ aBlock value:  GtGitElement new
]

{ #category : #accessing }
GtGitPhlowTool >> icon [
	^ BrGlamorousVectorIcons branching
]

{ #category : #accessing }
GtGitPhlowTool >> tabLook [
	^ BrGlamorousTabSwitcherWithIconAptitude
]
