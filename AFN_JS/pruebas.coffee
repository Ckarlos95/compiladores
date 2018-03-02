

b_as_a = new AFN('b').cerraduraAsterisco().concatenaAFN new AFN 'a'
b = new AFN 'b'
ejemplo = b.uneAFN b_as_a
ejemplo.concatenaAFN new AFN 'a'
console.log '**********************************************'
console.log ejemplo.cadenaValida t for t in ['aa', 'baa', 'ba', 'bbaa', 'bbbbbaa', 'bbbbbbbbbbaa', 'jiasfjlasfas', 'asfasjfjaskfjsal'] by 1
console.log '====================================================='
console.log '====================================================='

ejemploAFD = ejemplo.toAFD()
console.log ejemploAFD.cadenaValida t for t in ['aa', 'baa', 'ba', 'bbaa', 'bbbbbaa', 'bbbbbbbbbbaa', 'jiasfjlasfas', 'asfasjfjaskfjsal'] by 1

#Automatas de prueba
b = new AFN('b')
b_2 = new AFN('b').cerraduraAsterisco()
a = new AFN('a')
a_2 = new AFN('a')
b_3 = b_2.concatenaAFN(a)
b_4 = b.uneAFN(b_3)
b_5 = b_4.concatenaAFN(a_2)

console.log "Estados del AFN: " + b_5.estados.length

afdB_5 = b_5.toAFD()

console.log "Estados del AFD: " + afdB_5.estados.length

afdB_5.tabla()
afdB_5.imprimirTabla()



#Autómatas del pizarrón
aut_a = new AFN 'a'
aut_b = new AFN 'b'
aut_c = new AFN 'c'
aut_d = new AFN('d').cerraduraMas()
aut_ab = aut_a.uneAFN aut_b
aut_bc = aut_b.uneAFN aut_c
aut_bc.cerraduraAsterisco()
aut_a1 = new AFN('a')
aut_b1 = new AFN('b')
aut_a1.uneAFN aut_b1
aut_a1.cerraduraAsterisco()
aut_ab.concatenaAFN aut_bc.concatenaAFN aut_d.concatenaAFN aut_a1

console.log "\n\nEstados del AFN: " + aut_ab.estados.length

aut_ab_afd = aut_ab.toAFD()

console.log "Estados del AFD: " + aut_ab_afd.estados.length

afdAutomata = aut_ab.toAFD()

afdAutomata.tabla()
afdAutomata.imprimirTabla()

console.log aut_ab.cadenaValida t for t in ['abccbddd','abccbdddaab','bcbcbdbaaa','bcbcbdbaaac']

#Automatas de prueba AFN -> AFD

aut_s = new AFN('s').cerraduraInterrogacion().concatenaAFN new AFN('d').cerraduraMas()
aut_s.setToken(10)
aut_s1 = (new AFN('s').cerraduraInterrogacion().concatenaAFN new AFN('d').cerraduraMas()).concatenaAFN new AFN('.').concatenaAFN new AFN('d').cerraduraMas()
aut_s1.setToken(20)
aut_l = new AFN('l').concatenaAFN(new AFN('l').uneAFN new AFN('d')).cerraduraAsterisco()
aut_e = new AFN('e').cerraduraMas()
aut_e.setToken(40)
aut_m = new AFN '+'
aut_m.setToken(50)
aut_m1 = new AFN '-'
aut_m1.setToken(60)
aut_m2 = new AFN('+').concatenaAFN new AFN '+'
aut_m2.setToken(70)

autUnion = new AFN().unionAnalisisLex(aut_s,aut_m1,aut_m2,aut_e,aut_l,aut_s1)

afdUnion = autUnion.toAFD()

afdUnion.tabla()
afdUnion.imprimirTabla()












#console.log "\nTabla del AFD"
#for fila in afdB_5.tabla() by 1
  #console.log "------------------------"
  #for columna in fila by 1
  #console.log fila
#console.log "\n"

#console.log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

#b_as_a = new AFN('b').cerraduraAsterisco().concatenaAFN new AFN 'a'
#b = new AFN 'b'
#ejemplo = b.uneAFN b_as_a
#ejemplo.concatenaAFN new AFN 'a'
#console.log ejemplo.estados.length

#b_as_a_2 = new AFN('c').cerraduraMas().concatenaAFN new AFN 'b'
#b_2 = new AFN 'd'
#ejemplo_2 = b_2.uneAFN b_as_a_2
#ejemplo_2.concatenaAFN new AFN 'e'
#console.log ejemplo_2.estados.length

#ejemploP = ejemplo_2.unionAnalisisLex(ejemplo,ejemplo)
#console.log ejemploP.edosAceptacion.length

#ejemploP.setToken(1000)
#console.log 'Token: ' + ejemploP.getToken()
#console.log '**********************************************'
#console.log ejemploP.cadenaValida t for t in ['aa', 'baa', 'ba', 'bbaa', 'bbbbbaa', 'bbbbbbbbbbaa', 'jiasfjlasfas', 'asfasjfjaskfjsal'] by 1
#console.log '====================================================='
#console.log '====================================================='
#ejemploAFD = ejemploP.toAFD()

#for fila in ejemploAFD.tabla() by 1
  #console.log "------------------------"
  #for columna in fila by 1
    #console.log columna
  #console.log "\n"

#ejemploAFD.setToken(1000)
#console.log ejemploAFD.edosAceptacion.length
#console.log 'Token: ' + ejemploAFD.getToken()
#console.log '**********************************************'
#console.log ejemploAFD.cadenaValida t for t in ['aa', 'baa', 'ba', 'bbaa', 'bbbbbaa', 'bbbbbbbbbbaa', 'jiasfjlasfas', 'asfasjfjaskfjsal'] by 1

#ejemploAFD.tabla()

#letra = new AFN('a','z')
#numero = new AFN('0','9')
#letra_numero = letra.cerraduraAsterisco().concatenaAFN(numero.cerraduraMas())
#letra_numero.concatenaAFN(letra.cerraduraMas())
#letra_numero.concatenaAFN(numero.cerraduraInterrogacion())
#console.log '**********************************************'
#console.log letra_numero.cadenaValida t for t in ['dasdas1323123131deaaedaeae4','gdgd666dagdgagdagd666adgagda','342342342sdfsdfsdfs5'] by 1
#console.log '====================================================='
#console.log '====================================================='

#letra_numero_AFD = letra_numero.toAFD()
#console.log letra_numero_AFD.cadenaValida t for t in ['dasdas1323123131deaaedaeae4','gdgd666dagdgagdagd666adgagda','342342342sdfsdfsdfs5'] by 1
console.log '********************************************************'

gg = new AFN

console.log typeof gg

pruebaAlv = new AFN().fromRegex '(b|b*a)a'
console.log "Cantidad estados AFN: #{pruebaAlv.estados.length}"
console.log pruebaAlv.cadenaValida t for t in ['aa', 'baa', 'ba', 'bbaa', 'bbbbbaa', 'bbbbbbbbbbaa', 'jiasfjlasfas', 'asfasjfjaskfjsal'] by 1
pruebaAFD = pruebaAlv.toAFD()
console.log "Cantidad estados AFD: #{pruebaAFD.estados.length}"
console.log pruebaAFD.cadenaValida t for t in ['aa', 'baa', 'ba', 'bbaa', 'bbbbbaa', 'bbbbbbbbbbaa', 'jiasfjlasfas', 'asfasjfjaskfjsal'] by 1
